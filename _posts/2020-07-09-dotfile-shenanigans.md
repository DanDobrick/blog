---
title: "Dotfile Shenanigans"
date: 2020-07-09
published: 2020-07-09
categories: software
tags: [dotfiles, shell, bash, zsh]
is_post: true
github: https://github.com/DanDobrick/dotfiles
---
Recently I watched [this video](https://www.youtube.com/watch?v=V0p7pWSxOXw) from RubyConf 2018 about dotfiles and decided to customize my own setup across my various systems (a personal Macbook, a work Macbook and a personal Linux server). If you're not familiar with the concept of dotfiles, I'd watch the first few minutes of that video before continuing to read.
<!--more-->

If you just wanted to just check out my dotfiles I've linked them above (there's even an install script if you love my setup), but I've picked out a few tweaks that I like and talk through them below
- [RCM and storing dotfiles in github](#rcm)
- [Specific Dotfiles](#dotfiles)

## RCM

One of the most powerful things you can do with dotfiles is store them in version control and keep them updated across your various systems. This allows you to keep your workflow the same regardless of the machine you're working on.

Thoughtbot created this cool tool called [rcm](https://github.com/thoughtbot/rcm) that handles symlinking your dotfiles a location you specify to your home folder; making it easy to make changes across systems. Combining RCM and a [couple](https://github.com/DanDobrick/dotfiles/blob/39dd2c0c68bc91885b9a1d896a5c73c9f3e60059/zshrc#L128) of [scripts](https://github.com/DanDobrick/dotfiles/blob/39dd2c0c68bc91885b9a1d896a5c73c9f3e60059/zshrc#L179) I've written, all I have to do is push up a change to github and execute a function called `update` on any system that has my dotfiles installed.

Setting up RCM is DEAD simple; First we need to install `rcm`.

If you're not running OSX or don't use homebrew, you'll need to follow the install instructions [on rcm's github page](https://github.com/thoughtbot/rcm#installation)

```bash
$ brew tap thoughtbot/formulae
$ brew install rcm
```

Then use `mkrc` to add your dotfiles to a new dotfile directory `~/.dotfiles`. (See rcm documentation for customizing this location)

```bash
$ mkrc .gitconfig .zshrc .rspec .p10k
```

Finally syncronize your home directory (the `-v` flag is for verbose output)

```bash
$ rcup -v
```

Now all your dotfiles live in `~/.dotfiles` (without the `.` prefix) and are symlinked to your home directory (with the `.` prefix)!

Then you can add `~/.dotfiles` do your version control of choice and sync all your systems!

## Dotfiles

I have a few dotfile tweaks that I thought may have a broader application than just my system. Some are modifications of things I saw on the RubyConf video and some are straight stolen from other people dotfile repos. But that's another awesome thing about people making their dotfiles open-source: you can take their ideas and either save yourself some time or make them better!

### `.pryrc`
Dotfile for the [pry gem](https://github.com/pry/pry).

My `pryrc` consists of this snippet which uses [`awesome_print`](https://github.com/awesome-print/awesome_print) for all your pry sessions if it's installed in your default rvm gemset. The syntax for your `pryrc` is simple ruby which is nice.


```ruby
if `which rvm`.empty?
  warn 'RVM not installed, attempting to load awesome_print from gemfile'
else
  gemdir = `rvm gemdir`
  path = "#{gemdir.chomp}/gems/awesome_print-1.8.0/lib/"
  $LOAD_PATH << path
end

begin
  require 'awesome_print'
  AwesomePrint.pry!
rescue LoadError
  warn 'awesome_print not installed'
end
```

### `.zshrc` or `.bash_profile`
Drop these in your `bash_profile` or `zshrc`.

##### The classic `mkcd`
A simple function to make directory then immediately `cd` into it. 

```bash
function mkcd() {
  mkdir -p "$1" && cd "$1";
}
```

##### Colorful `ls` on both OSX and Linux

```bash
# ls color + symbols for OSX and Linux
if ls --help 2>&1 | grep -q -- --color
then
  alias ls='ls --color=auto -F'
else
  alias ls='ls -GF'
fi
```

##### Oh My Zsh + plugins
Some people dislike Oh My Zsh, but I am personally a fan and have found myself loving the various [plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins) that are available, in particular the aliases that the `git` plugin provides:

{: .table .table-striped}
Alias | Command
----- | -------
ggpush | git push origin "$(git_current_branch)"
gwip | Commit wip branch
gunwip | Uncommit wip branch

### `.rcrc`

Dotfile to control rcm. I use it to exclude certain files and folders that I do _not_ want symlinked to my home directory when I use `rcup`.

```bash
EXCLUDES="README.md githooks/* install.sh"
```
