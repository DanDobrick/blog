# https://www.dandobrick.com/blog
Blog using jekyll that lives at [the above url](https://www.dandobrick.com/blog).

Theme taken from https://github.com/alainpham/alainpham.github.io, then modified a bunch.

## Upcoming Topics
Posts I want to write but haven't yet

- Postgres indices and Binary trees
- k8s
  - [Setting up a single Node k8s cluster on a single Digital Ocean droplet](https://dandobrick.com/blog/tags/#do-k8s-node) (This link wil be dead until I publish the first post in this series)

## Drafts:

Create a draft: `thor draft:create "tile in quotes"`

Publish a draft: `thor draft:publish`

For more options see `thor help draft`

## Todo
### Probably
- Add proper links to TOC in excerpts on the home page.
- Fix Thor draft:create. Categories should not be an array and line breaks are broken
- `thor draft:publish`
  - Handle no new drafts (incl. new commit msg)
- Change thor functions to be `thor draft publish` and `thor draft create`
- Split up css into different files.

### Maybe
- Get a generic image for "no_image" posts
- Update thor create function to allow for interactive mode (make default if no args given to script)
- Make thor script executable
- Rewrite thor script in another language
  - Rust?
  - Go?
  - C?
  - C++?
  - Java?
  - ASM (j/k)

## License
The content of this project is licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode), and the underlying source code used to format and display that content is licensed under the [MIT license](https://github.com/DanDobrick/blog/blob/master/LICENSE)
