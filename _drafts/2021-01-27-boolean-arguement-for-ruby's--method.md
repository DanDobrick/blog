---
title: Boolean Arguement For Ruby's `methods` Method
date: 2021-01-27
published: 2021-01-27
tags: [ruby]
is_post: true
---
This paragraph will be used as the excerpt if you don't have an "excerpt" front matter. Also if you don't use the "more" below, the index will take the first paragraph as the excerpt

As a note, you might need to edit the title both in the front-matter and in the header below. This script will capitalize words like "is" and "or"
<!--more-->

## Boolean Arguement For Ruby's `methods` Method
Many people know that you can call `.methods` on an object in ruby to get an array of possible methods for that object:

```ruby
[1, 2, 3].methods
# => ["!", "!=", "!~", "&", ...]
```
This is really nice, but it also gives you _all_ the methods that the object inherits, so a custom object will return a bunch of things you aren't looking for.

```ruby
class MyCustomObject
  def sweet_method
    p 'Possibly the coolest method ever'
  end
end

custom_object = MyCustomObject.new
custom_object.methods
# => [:sweet_method, :pry, :__binding__, :methods, :singleton_methods, ...]
custom_object.methods.length
# => 69
```

This can get pretty cluttered when you're looking for something specific, so up until recently I would do something like this:

```ruby
custom_object.methods - Object.methods
# => [:sweet_method]
```
