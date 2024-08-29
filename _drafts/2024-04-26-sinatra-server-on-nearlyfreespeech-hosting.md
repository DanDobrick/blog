---
title: Sinatra Server On NearlyFreeSpeech Hosting
date: 2024-04-26
published: 2024-04-26
tags: [hosting, sinatra, ruby]
is_post: true


excerpt: this is an optional excerpt that has priority over the first paragraph.
---
A while ago, I had a personal website home page that displayed information I found relevant. I hosted it on DigitalOcean and [even wrote a blog post about it]({{ site.baseurl }}/posts/ufw-linux-firewall-and-how-to-use-it/). That site has been down for something like four years so I decided to create a _new_ home page, using [NearlyFreeSpeech.net](https://www.nearlyfreespeech.net/) for hosting. Unfortunately the docs do not have a tutorial for Ruby or Sinatra so I decided to write one.
<!--more-->

## Sinatra Server On NearlyFreeSpeech Hosting
[NearlyFreeSpeech.net](https://www.nearlyfreespeech.net/) has very cheap hosting, and 

## Sign up

## Setup
While the server has a system ruby installed, it's best practice NOT to use it and in the case of NearlyFreeSpeech, your user doesn't have access to install gems for the system ruby, so we need to install rvm first.

Following the directions at <>



- SSH
- Install RVM
- copy code
  - I used a gui SFTP tool
- bundle install
- run to test
- Create runner script
- test runner script
- set up daemon in UI
- test daemon
- logs are in logs
- Set up proxies in UI
