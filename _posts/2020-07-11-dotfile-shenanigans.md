---
title: "Dotfile Shenanigans"
date: 2030-07-11
published: 2030-07-11
comments: true
categories: development
tags: [dotfiles, shell, bash, zsh]
is_post: true
excerpt: 
---
Recently I watched [this video](https://www.youtube.com/watch?v=V0p7pWSxOXw) from RubyConf 2018 about dotfiles and decided to customize my own setup across the 3 computers I use daily (personal Macbook, work Macbook and personal Linux server). If you're not familiar with the concept of dotfiles, I'd watch the first few minutes of that video before continuing to read this post.
<!--more-->

I was introduced to dotfiles was in bootcamp where one of the instructors gave us all a copy of their `.bash_profile` which contained a few ruby-based aliases and a nice shell prompt showing the current git branch. Prior to watching this video I had literally copy/pasted that `.bash_profile` onto multiple computers and had no idea how much of it worked. That RubyConf video convinced me that I'm missing out on some cool stuff and should probably figure out how to tweak things for myself.

## Zsh
Because I was already going to screw with my shell I decided to change everything and move from using bash to using [Z shell](https://www.zsh.org/)(zsh) and [iTerm2](https://iterm2.com/). Zsh has some cool features that I'm not gonna go over, but I wanted to talk about some of my zsh-specific dotfiles

- how to dl and install
- r10k
- mention a few things in zshrc

The very first thing I did was to check out what dotfiles I currently had and what they all were doing; luckily I only really had configuration in my `~/.bash_profile` and global gitconfig(`~/.gitconfig`). Next I backed up my bash profile and replaced it with an empty file

```bash
$ mv ~/.bash_profile ~/.bash_profile.backup
$ touch ~/.bash_profile
```

## Zsh
## RCM + github
## Dotfiles
## Update scripts
