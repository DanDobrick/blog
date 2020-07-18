---
title: "`ActiveRecord.dup` and `constantize`"
date: 2020-07-17
published: 2020-07-16
categories: til
tags: [active-record, ruby]
is_post: true
no_image: true
---

I'm still unsure how I want to use this blog and wether I intend on creating a separate section for these short "TIL" posts or if I want to keep them here, but for today I'm combining two TILs into a longer post. I'm also using this to experiment with a post not having an image associated with it; we'll see if that bugs me and I end up changing it or not.

This week I've learned a bit about the limitations ActiveRecord's `dup` function as well as how `constantize` works.

- [1. Active Record's `dup` method](#1-active-records-dup-method)
- [2. Ruby's `constantize` assumes top-level constant](#2-rubys-constantize-assumes-top-level-constant)

<!--more-->

## 1. Active Record's `dup` method
This method creates a new record that is a duplicate of whatever record you're calling it on. Unfortunately it intentionally doesn't [duplicate your associations](https://apidock.com/rails/ActiveRecord/Core/dup) so you'll need to duplicate those manually.

From the documentation: 
> ...copies the object’s attributes only, not its associations. The extent of a “deep” copy is application specific and is therefore left to the application to implement according to its need.

**Example**

For a setup like this:

```ruby
class ParentObject < ActiveRecord::Base
  has_many :child_objects

  attr_reader :name
end

class ChildObject < ActiveRecord::Base
  belongs_to :parent_object
  attr_reader: name
end

parent = ParentObject.create!(name: 'Jimbo Jones')

kearney = ChildObject.create!(name: 'Kearney Zzyzwicz')
parent.child_objects << kearney

lisa = ChildObject.create!(name: 'Lisa Simpson')
parent.child_objects << lisa

dolph = ChildObject.create!(name: 'Dolph Starbeam')
parent.child_objects << dolph

```
If we wanted to duplicate the record and it's associations we would need to do duplicate each child object like this:

```ruby
new_parent = parent.dup

new_children = parent.child_objects.map(&:map)

new_parent.child_objects << new_children

new_parent.name == parent.name # => true
new_parent.id == parent.id # => false

new_parent.child_objects.map(&:name).sort == parent.child_objects.map(&:name).sort # => true
new_parent.child_objects.map(&:id).sort == parent.child_objects.map(&:id).sort # => false
```
NOTE: `dup` does not duplicate the values in the timestamps.

## 2. Ruby's `constantize` assumes top-level constant

While writing a service that programmatically retrieves constants living at the class level, I wrote something that looks like this:

```ruby
class MyAwesomeService
  TYPE_ONE_CONSTANT = 'type_one'.freeze
  TYPE_TWO_CONSTANT = 'type_two'.freeze
  TYPE_THREE_CONSTANT = 'type_three'.freeze

  def initialize(constant_type_name)
    @value_from_constant = "#{constant_type_name.upcase}_CONSTANT".constantize
  end

  def execute!
    puts "The value for the constant you selected was #{@value_from_constant}"
  end
end

MyAwesomeService.new('type_one') # => NameError: uninitialized constant TYPE_ONE_CONSTANT
```

This is because `constantize` assumes the constant is at the top-level:
```ruby
"TYPE_ONE_CONSTANT".constantize # => ::TYPE_ONE_CONSTANT
```

Our implementation actually implements that constant in the `MyAwesomeService` namespace: `MyAwesomeService::TYPE_ONE_CONSTANT`

So instead, if we wanted to retrieve this constant we would could use either [`self.class.const_get()`](https://apidock.com/ruby/Module/const_get) or prepend the expression with `MyAwesomeService::`

```ruby
constant_type_name = 'type_one'
self.class.const_get("#{constant_type_name.upcase}_CONSTANT") # => MyAwesomeService::TYPE_ONE_CONSTANT
# or
"MyAwesomeService::#{constant_type_name.upcase}_CONSTANT".constantize # => MyAwesomeService::TYPE_ONE_CONSTANT
```

Since the time I wrote this I've updated the implementation so it doesn't require this kind of pattern, but knowing the way the assumptions `constantize` makes is very useful.
