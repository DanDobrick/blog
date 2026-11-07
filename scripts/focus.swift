// Prints the vertical "point of interest" of an image as a percentage from the
// top (0-100). Used by `thor draft:photo` to pick which horizontal strip of a
// photo to show in the home page feed.
//
// Uses Apple's Vision saliency: objectness (distinct subjects) multiplied by
// attention (where the eye lands), then a coarse-to-fine search that narrows in
// on the strongest horizontal band over several passes. Falls back to a single
// heat map, then to 50. See `focusPercent` for details.
//
// Usage: swift scripts/focus.swift path/to/image.jpg
import Foundation
import Vision
import CoreVideo
import ImageIO

guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write(Data("usage: focus.swift IMAGE\n".utf8))
    exit(2)
}

let url = URL(fileURLWithPath: CommandLine.arguments[1])

/// Reads a request's saliency heat map as a flat [Float] (row-major, w x h).
func heatMap(for request: VNImageBasedRequest) -> (values: [Float], w: Int, h: Int)? {
    let handler = VNImageRequestHandler(url: url, options: [:])
    guard (try? handler.perform([request])) != nil,
          let obs = request.results?.first as? VNSaliencyImageObservation else { return nil }

    let pb = obs.pixelBuffer
    CVPixelBufferLockBaseAddress(pb, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pb, .readOnly) }
    let w = CVPixelBufferGetWidth(pb), h = CVPixelBufferGetHeight(pb)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pb)
    guard let base = CVPixelBufferGetBaseAddress(pb) else { return nil }

    var values = [Float](repeating: 0, count: w * h)
    for y in 0..<h {
        let row = base.advanced(by: y * bytesPerRow).assumingMemoryBound(to: Float.self)
        for x in 0..<w { values[y * w + x] = row[x] }
    }
    return (values, w, h)
}

/// Scales a heat map so its peak is 1.
func normalized(_ values: [Float]) -> [Float] {
    guard let peak = values.max(), peak > 0 else { return values }
    return values.map { $0 / peak }
}

/// Coarse-to-fine search for the most salient horizontal band of a heat map.
///
/// Start with the whole image. Each pass shrinks the window (to ~60% of its
/// height) and slides it to wherever it contains the most saliency, so every
/// pass zooms in on the "best" part of the previous one. Stop once the window is
/// small, and return its center (0-100 from the top).
func bestBand(rows: [Float], targetRows: Int) -> Int {
    let h = rows.count
    let target = max(2, targetRows)
    var start = 0
    var size = h
    while size > target {
        let prevEnd = start + size
        size = max(target, Int((Float(size) * 0.6).rounded()))
        var best = start, bestSum: Float = -1
        var y = start
        while y + size <= prevEnd {
            let sum = rows[y..<(y + size)].reduce(0, +)
            if sum > bestSum { bestSum = sum; best = y }
            y += 1
        }
        start = best
    }
    return Int((Float(start) + Float(size) / 2) / Float(h) * 100)
}

/// Objectness finds distinct subjects but treats a whole subject as one flat
/// blob; attention finds where the eye actually lands (eyes, faces, bright
/// things). Multiplying them keeps only points that are both, so we land on the
/// best part of the main subject. Falls back to whichever map is available.
func focusPercent(bannerFraction: Float) -> Int {
    let objectness = heatMap(for: VNGenerateObjectnessBasedSaliencyImageRequest())
    let attention = heatMap(for: VNGenerateAttentionBasedSaliencyImageRequest())

    var combined: [Float]
    var w = 0, h = 0
    if let o = objectness, let a = attention, o.w == a.w, o.h == a.h {
        let no = normalized(o.values), na = normalized(a.values)
        combined = zip(no, na).map { $0 * $1 }
        w = o.w; h = o.h
    } else if let one = objectness ?? attention {
        combined = normalized(one.values); w = one.w; h = one.h
    } else {
        return 50
    }

    var rows = [Float](repeating: 0, count: h)
    for y in 0..<h {
        var sum: Float = 0
        for x in 0..<w { let v = combined[y * w + x]; sum += v * v }
        rows[y] = sum
    }
    guard rows.reduce(0, +) > 0 else { return 50 }
    return bestBand(rows: rows, targetRows: Int((bannerFraction * 0.25 * Float(h)).rounded()))
}

// Banner strip is 5:1 (matches .photo-feed-image in _sass/main.scss).
var bannerFraction: Float = 0.27
if let src = CGImageSourceCreateWithURL(url as CFURL, nil),
   let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
   let pw = props[kCGImagePropertyPixelWidth] as? Double,
   let ph = props[kCGImagePropertyPixelHeight] as? Double, ph > 0 {
    bannerFraction = Float(min(1, (pw / 5) / ph))
}

print(min(max(focusPercent(bannerFraction: bannerFraction), 0), 100))
