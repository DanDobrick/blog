---
title: "Dotfile Shenanigans"
date: 2020-07-09
published: 2020-07-09
comments: true
categories: development
tags: [dotfiles, shell, bash, zsh]
is_post: true
github: https://github.com/DanDobrick/dotfiles
---
Recently I watched [this video](https://www.youtube.com/watch?v=V0p7pWSxOXw) from RubyConf 2018 about dotfiles and decided to customize my own setup across my various systems (a personal Macbook, a work Macbook and a personal Linux server). If you're not familiar with the concept of dotfiles, I'd watch the first few minutes of that video before continuing to read.
<!--more-->

If you just wanted to just check out my dotfiles I've linked them above, but I've picked out a few tweaks that I like and talk through them below
- [RCM and storing dotfiles in github](#rcm)
- [Specific Dotfiles](#dotfiles)
- [My Update scripts](#update_scripts)

## RCM

A neat thing you can do with your dotfiles is store them in github and keep them updated across your various systems. Before watching the above video I had tried doing this by uploading the giles to github and simply copy/pasting them to update each machine; needless to say this got tedious really quickly.

Thoughtbot wrote this cool tool called [rcm](https://github.com/thoughtbot/rcm) that handles symlinking your dotfiles from a repo you specify to your home folder; making it easy to make changes across systems. Combining RCM and a [couple](https://github.com/DanDobrick/dotfiles/blob/39dd2c0c68bc91885b9a1d896a5c73c9f3e60059/zshrc#L128) [scripts](https://github.com/DanDobrick/dotfiles/blob/39dd2c0c68bc91885b9a1d896a5c73c9f3e60059/zshrc#L179) I've written, all I have to do is push up a change to github and execute a function called `update` on any system that has my dotfiles installed.

## Dotfiles

