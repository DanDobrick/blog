---
title: Setting Up K9s With Private Docker Repo
date: 2020-08-05
published: 2020-08-05
tags: []
is_post: true


excerpt: this is an optional excerpt that has priority over the first paragraph.
---
This paragraph will be used as the excerpt if you don't have an "excerpt" front matter. Also if you don't use the "more" below, the index will take the first paragraph as the excerpt

As a note, you might need to edit the title both in the front-matter and in the header below. This script will capitalize words like "is" and "or"
<!--more-->

## Setting Up K9s With Private Docker Repo

```bash
$ echo -n "<username>:<password>" | base64
```

```json
{
	"auths": {
		"https://index.docker.io/v1/": {
			"auth": "<encoded-creds>"
		}
	}
}
```
