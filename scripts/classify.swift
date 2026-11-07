// Prints up to N short title suggestions for a photo, one per line, best first.
// Used by `thor draft:photo` when you don't give it a title.
//
// Uses Apple's on-device Vision image classifier (no network, no generative
// AI). Its labels come in hierarchies (lake > water body > liquid > outdoor), so
// we drop generic labels and keep only confident, specific ones.
//
// Usage: swift scripts/classify.swift path/to/image [max_results]
import Foundation
import Vision

guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write(Data("usage: classify.swift IMAGE [N]\n".utf8))
    exit(2)
}

let url = URL(fileURLWithPath: CommandLine.arguments[1])
let limit = CommandLine.arguments.count > 2 ? Int(CommandLine.arguments[2]) ?? 3 : 3
let minConfidence: Float = 0.10

// Labels that are true but make boring titles.
let generic: Set<String> = [
    "outdoor", "indoor", "sky", "blue_sky", "cloudy_sky", "structure", "land", "liquid", "water",
    "water_body", "material", "wood_processed", "conveyance", "portal", "daytime", "nighttime",
    "celebration", "art", "decoration", "frame", "clothing", "food", "vegetable", "fruit", "animal",
    "people", "adult", "teen", "furniture", "interior_room", "interior_shop", "raw_glass", "textile",
    "plant", "machine", "vehicle", "container", "tool", "toy", "text", "sport", "recreation",
    "sunbathing", "event", "display", "cloud", "sunset_sunrise", "light",
]

let request = VNClassifyImageRequest()
do {
    try VNImageRequestHandler(url: url, options: [:]).perform([request])
} catch {
    exit(0) // no suggestions; caller falls back to the date
}

let results = (request.results ?? [])
    .sorted { $0.confidence > $1.confidence }
    .filter { $0.confidence >= minConfidence && !generic.contains($0.identifier) }

// Skip near-duplicates like "Chair" / "Folding Chair" (same last word).
var lastWords = Set<String>()
var printed = 0
for r in results {
    let words = r.identifier.split(separator: "_").map { String($0).capitalized }
    guard words.count <= 3, let last = words.last else { continue }
    if lastWords.insert(last).inserted {
        print(words.joined(separator: " "))
        printed += 1
        if printed >= limit { break }
    }
}
