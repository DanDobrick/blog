---
title: "Dotfile Shenanigans"
date: 2030-07-09
published: 2030-07-09
comments: true
categories: development
tags: [dotfiles, shell, bash, zsh]
is_post: true
excerpt: 
---
Recently I watched [this video](https://www.youtube.com/watch?v=V0p7pWSxOXw) from RubyConf 2018 about dotfiles and decided to customize my own setup across the computers I use daily (a personal Macbook, a work Macbook and a personal Linux server). If you're not familiar with the concept of dotfiles, I'd watch the first few minutes of that video before continuing to read this post.
<!--more-->

I broke this post up into various topics related to how I tweaked my setup:
- [My background with Dotfiles](#my_background)
- [Using ZSH + iTerm](#zsh)
- [Using RCM and storing dotfiles in github](#rcm)
- [Specific Dotfiles](#dotfiles)
- [Update scripts](#update_scripts)

## My Background
I was introduced to dotfiles in bootcamp where one of the instructors gave us a copy of their `.bash_profile`, which contained some aliases and a nice shell prompt showing the current git branch and current directory. Prior to watching this video I had literally copy/pasted that `.bash_profile` onto multiple computers and had no idea how much of it worked. This caused me to accidentally break things when adding/removing aliases to my `.bash_profile` and generally made me scared of bash in general. Watching that video convniced me to learn how all this worked and tweak things how _I_ like them rather than how a DBC instructor set their machine up.

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
## RCM
## Dotfiles
## Update scripts
