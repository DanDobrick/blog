# https://www.dandobrick.com/blog
Blog using jekyll that lives at [the above url](https://www.dandobrick.com/blog).

## Upcoming Topics
All Caught up!

## Drafts:

Create a draft: `thor draft:create "tile in quotes"`

Publish a draft: `thor draft:publish`

For more options see `thor help draft`

## Notes for writing posts
- To add classes to images, use the following syntax:
`![alt-text](path/to-/image.ext){: .class-name}`
for example:
`![Table Locks]({{ site.baseurl }}/assets/images/{{ page.id }}/table-locks.png){: .img-responsive}`

## Todo
- Adjust image sizes or implement some kind of image CDN?
- Center "top" image
- allow "top" to be either png or jpg
- Look into replacing my thor scripts with [jekyll-compose](https://github.com/jekyll/jekyll-compose)

I haven't done these in years; who knows if I ever actually will

- Add proper links to TOC in excerpts on the home page.
- Fix Thor draft:create. Categories should not be an array and line breaks are broken
- `thor draft:publish`
  - Handle no new drafts (incl. new commit msg)
- Change thor functions to be `thor draft publish` and `thor draft create`
- Split up css into different files.
- Fix broken css on tags page when there are multiple lines of tags
- Get a generic image for "no_image" posts
- Update thor create function to allow for interactive mode (make default if no args given to script)
- Make thor script executable
- Rewrite thor script in another language

## License
The content of this project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode), and the underlying source code used to format and display that content is licensed under the [MIT license](https://github.com/DanDobrick/blog/blob/master/LICENSE)

## Appendix
Theme was taken from https://github.com/alainpham/alainpham.github.io, then modified a bunch.