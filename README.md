# https://www.dandobrick.com/blog
Blog using jekyll that lives at [the above url](https://www.dandobrick.com/blog).

## Unexplored Games
- Do pagination if I ever get more posts

## Drafts:

Create a draft: `thor draft:create "tile in quotes"`

Publish a draft: `thor draft:publish`

For more options see `thor help draft`

### Photo posts

A photo post is a post that is just a picture (with an optional one-line caption). Create one with:

```
bundle exec thor draft:photo "Title in quotes" path/to/photo.heic
```

or leave the title off and let it suggest some:

```
bundle exec thor draft:photo path/to/photo.heic
```

It looks at the photo (`scripts/classify.swift`, Apple's on-device Vision classifier, no network) and offers up to 3 short titles like "Lake" or "Pumpkin", plus the date the photo was taken ("Sept 26, 2026"). Type a number, type your own title, or just press Enter for the date. Two photos with the same title get a number appended.

This will:
- convert the photo to a JPEG (HEIC, PNG, etc. are fine) and shrink it so the longest side is at most 2000px (smaller photos are not enlarged)
- save it as `assets/images/posts/<title-slug>/top.jpg`, plus a 600px center-cropped square `thumb.jpg` used on the home page and the `/photos/` grid
- create `_drafts/<date>-<title-slug>.md` with `photo: true` and a `photo` tag

In the home page feed a photo post looks like a normal card, with a wide banner strip of the photo. Which strip is chosen automatically (`scripts/focus.swift` uses macOS Vision saliency to find the main subject); override it with `-f 0-100` (0 = top, 100 = bottom) or by editing `photo_focus` in the draft. All photo posts are collected on the `/photos/` page (linked in the nav).

Then, optionally add a caption to the draft (or just delete the placeholder comment for no text), preview with `bundle exec jekyll serve --drafts`, and run `thor draft:publish` as usual.

Options: `-f 40` (banner focus), `-t tag1 tag2` (replaces the default `photo` tag), `-w 1600` (max pixel size), `-q 90` (JPEG quality). Needs macOS (uses the built-in `sips`). Note: `sips` doesn't strip EXIF data, so location info in the original photo may remain in the saved JPEG.

## Notes for writing posts
- To add classes to images, use the following syntax:
`![alt-text](path/to-/image.ext){: .class-name}`
for example:
`![Table Locks]({{ site.baseurl }}/assets/images/{{ page.id }}/table-locks.png){: .img-responsive}`

## Todo
- Center "top" image
- allow "top" to be either png or jpg
- Look into replacing my thor scripts with [jekyll-compose](https://github.com/jekyll/jekyll-compose)
- clean up CSS; consider splitting into different files.

I haven't done these in years; who knows if I ever actually will

- Add proper links to TOC in excerpts on the home page.
- Fix Thor draft:create. Categories should not be an array and line breaks are broken
- `thor draft:publish`
  - Handle no new drafts (incl. new commit msg)
- Change thor functions to be `thor draft publish` and `thor draft create`
- Fix broken css on tags page when there are multiple lines of tags
- Update thor create function to allow for interactive mode (make default if no args given to script)
- Make thor script executable
- Rewrite thor script in another language

## License
The content of this project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode), and the underlying source code used to format and display that content is licensed under the [MIT license](https://github.com/DanDobrick/blog/blob/master/LICENSE)

## Appendix
Theme was taken from https://github.com/alainpham/alainpham.github.io, then modified a bunch.