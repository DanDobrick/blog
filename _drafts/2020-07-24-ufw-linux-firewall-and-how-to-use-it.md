---
title: `ufw` - Linux Firewall And How To Use It
date: 2020-07-24
published: 2020-07-24
tags: ["do-learning", "ubuntu", "linux", "firewall", "server", "Heroku", "digital-ocean"]
is_post: true
categories: ["software"]
---
I've been tinkering with digital ocean and thinking about moving a personal project from Heroku to a DO droplet running a small k8s cluster. Both to learn about setting up k8s with a real-life example and because DO is cheaper than Heroku for my use-case.

INSERT `do-learning` tag link and talk about my learning journey.

Maybe insert a TOC here

Maybe screenshot a terminal and use that for top image.
<!--more-->

## Heroku vs Digital Ocean prices.
Heroku is free for 1000 hrs a month which is fine when you run 1 <insert Heroku Term> 24 hours a day or 2 <term> for 16 hours. <maybe talk about pinging endpoints to say alive>.

For this particular project I have the following setup:
- RedisToGo (free <addon?>) <talk more>
- postgres (free <addin?>) <talk more>
- Rails Server
- React
- sidekiq

Running Rails, React and my sidekiq daemon this on a single <term> is probably possible, but since I found a [$100 credit for Digital Ocean](link) I decided to embark on a learning journey.

After setting up a droplet and logging in as the root user, I realized that I was dumb and a DO droplet is simply a VPS and I could do whatever I wanted, but the only user that existed was `root`. If you're not familar with running a server this is kinda scary... so, even though my droplet was not running _anything_, I immediately deleted it and decieded to come back later.

<words> I found [this tutorial](link) from Digital Ocean that talked about setting up a non-root user<I should fix the above, because this is obvious> as well as configuring a firewall.

## Ufw - Linux Firewall And How To Use It

- Firewall
- What DO suggests
- What I did for DO <very little since it doesn't do anything>
- What I did for my home-based server

Bash-history for what I did at home
```bash
sudo ufw app list
sudo ufw status
sudo ufw app list
sudo ufw allow openSS
sudo ufw allow OpenSSH
# SINGLE QUOTES MATTER HERE
sudo ufw allow 'Lighttpd Full'
sudo ufw allow 'Lighttpd HTTP'
sudo ufw allow 'Lighttpd HTTPS'
sudo ufw app list
# FAKE PORT NUMBERS
sudo ufw allow 11111
sudo ufw allow 22222
sudo ufw enable
```
