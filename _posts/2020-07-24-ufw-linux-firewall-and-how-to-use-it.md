---
title: "`ufw` - Linux Firewall And How To Use It"
date: 2020-07-24
published: 2020-07-24
tags: ["do-k8s-node", "ubuntu", "linux", "k8s", "Heroku", "digital-ocean"]
is_post: true
categories: ["software"]
---
I've been tinkering a bit with Digital Ocean (use my referral link to get [$100 in Digital Ocean credit](https://m.do.co/c/991135433694 "Click for $100 in Digital Ocean credit")) and I've decided to move a small personal project from Heroku to a droplet running a small [Kubernetes](https://kubernetes.io/) (k8s) cluster. I want to do this both to learn about setting up k8s (very useful since I work with it daily) and because Digital Ocean is cheaper than Heroku for my use-case.

This will be the first post in a series about setting up this single-node k8s cluster on a [Digital Ocean](https://m.do.co/c/991135433694) droplet; check out the [`do-k8s-node` tag](/blog/tags/#do-k8s-node) to find the other posts in this series; I'll also be adding links to the next post in the series as I write them.

This first post is about the firewall built into Ubuntu: `ufw` as well as why I want to move from Heroku to [Digital Ocean](https://m.do.co/c/991135433694).

- [Ufw - Linux Firewall And How To Use It](#ufw---linux-firewall-and-how-to-use-it)
- [Heroku vs Digital Ocean prices](#heroku-vs-digital-ocean-prices)
  - [Free Digital Ocean Credit](#free-digital-ocean-credit)
  - [Heroku Costs](#heroku-costs)
<!--more-->

## Ufw - Linux Firewall And How To Use It
I found [a Digital Ocean tutorial](link) that talked about setting up your droplet and doing a few security tasks, including something I hadn't done in the past: configuring a firewall using `ufw`.

The manpage for `ufw` states:
> This program is for managing a Linux firewall and aims to provide an easy to use interface for the user.

And I'd have to agree: it's dead simple to setup. Do you have an Ubuntu computer and want to turn the firewall on, blocking all requests? Simple:

```bash
$ ufw enable
```

Well, not **that** simple, all `ufw` commands need to be run as `root` or using `sudo`, but I'm gonna omit that in all my examples.

Since I'm running this on a droplet--which is simply a VPS--I need ensure I maintain SSH access, so I made sure to allow OpenSSH **BEFORE** enabling the firewall:

```bash
$ ufw app list
Available applications:
  OpenSSH

$ ufw allow OpenSSH
Rules updated
Rules updated (v6)

$ ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
```
Done! Now the firewall is on and allowing SSH connections even if you're using a non-stardard ssh port, but if you wanted to allow specific ports for other applications, the command for that is simple as well!

```bash
$ ufw allow 1234
```

Once I setup the server on this droplet I'll be adding more firewall rules for the various services that I'll be running and I'll be sure to include those commands in the posts where I setup the services.

## Heroku vs Digital Ocean prices
Since I mentioned that I'm migrating from Heroku to [Digital Ocean](https://m.do.co/c/991135433694 "Click for $100 in Digital Ocean credit"), I thought it might be interesting to discuss the _why_ of this decision.

### Free Digital Ocean Credit

First off, I probably wouldn't have tinkered with Digital Ocean if I hadn't found someone's referral link that gives you $100 of credit to use in your first 60 days. Because I found this so useful, I want to make sure I share [my link](https://m.do.co/c/991135433694 "Click for $100 in Digital Ocean credit") as well. $100 ain't shabby!

### Heroku Costs

Heroku charges for each hour your ["dyno"](https://devcenter.heroku.com/articles/dynos) (essentially a lightweight container) is running and, for the free tier, they give you 1000 hours/mo and stop your dynos after an inactivity period of 30 mins. This is fine if you want to wait for your dynos to spin up or if you only have 1 dyno running and are pinging your dyno every ~25 mins, but once you start running multiple processes, this 1000 hours gets spent FAST. Currently I have 3 dynos running and pinging them using `curl` + `cron` to keep them up ~1000/3 hours a month; trying to keep my personal project dyno's running as much as possible during the day without incurring a cost.

If I wanted to upgrade to Heroku's "hobby" level service I would end up paying $7/dyno which comes out to $21 per month to run a simple [Rails](https://bashonrails.org/) app using [Sidekiq](https://sidekiq.org/) and [React](https://reactjs.org/) which seems pretty pricey to me. When I found the aforementioned [link for a $100 credit](https://m.do.co/c/991135433694 "Click for $100 in Digital Ocean credit") I was stoked to see what I could do with Digital Ocean.

I'm sure I could find a way to run my whole stack on Heroku using only one dyno and managing my own VPS is assuredly more work, but playing with k8s is way more fun. Plus having a whole VPS with 3 cores for less than it would cost to run 3 Heroku dynos sounds like a better deal to me.