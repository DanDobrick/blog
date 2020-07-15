---
title: "TIL - Small things in July"
date: 2020-07-31
published: 2020-07-31
categories: til
tags: [til, active-record, ruby]
is_post: true
no_image: true
---

Instead of creating a bunch of new posts that have a single code snippet, a method I just learned about or something that is not interesting enough to want to write about, I compiled a bunch of small things from July into a single "small things" post.

- [1. Active Record's `dup` method](#1-active-records-dup-method)

<!--more-->

## 1. Active Record's `dup` method
This method creates a new record that is a duplicate of whatever record you're calling it on. Unfortunately it intentionally doesn't [duplicate your associations](https://apidock.com/rails/ActiveRecord/Core/dup) so you'll need to duplicate those manually.

> ...it copies the object’s attributes only, not its associations. The extent of a “deep” copy is application specific and is therefore left to the application to implement according to its need.

**Example**

For a setup like this:

```ruby
class ParentObject < ActiveRecord::Base
  has_many :child_objects
end

class ChildObject < ActiveRecord::Base
  belongs_to :parent_object
end

parent = ParentObject.create!

3.times do 
  child = ChildObject.create!
  parent.child_objects << child
end
```
If we wanted to duplicate the record and it's associations we would need to do duplicate each child object like this:

```ruby
new_parent = parent.dup

new_children = parent.child_objects.map(&:map)

new_parent.child_objects << new_children
```