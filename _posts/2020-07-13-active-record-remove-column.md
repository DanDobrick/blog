---
title: "TIL - Some stuff about Active Record"
date: 2020-07-13
published: 2020-07-13
comments: true
categories: til
tags: [til, ruby, active-record]
is_post: true
excerpt: A couple things about active record that I learned this week.
---

### 1. Active Record uses a column called `type` for object inheritance

Taken from [the docs](https://api.rubyonrails.org/v4.2.11/classes/ActiveRecord/Inheritance.html):

> Active Record allows inheritance by storing the name of the class in a column that by default is named “type” (can be changed by overwriting Base.inheritance_column)

For example, when you have classes that look like this:

```ruby
class Person < ActiveRecord::Base; end

class Child < ActiveRecord::Base; end
```

and create a child object

```ruby
Child.create(name: 'Billy')
```

Active Record stores the value `"Child"` in billy's `type` column. Then we can retrieve Billy

```ruby
Person.where(name: 'Billy')
```

Active Record will use the value in `type` to return an object of type `Child`.


### 2. The method `remove_column` needs a `type` to be used in a `change` block.

The method signature for Active Record's [`remove_column`](https://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaStatements/remove_column) method looks like this:

```ruby
remove_column(table_name, column_name, type = nil, options = {})
```

`type` and `options` are optional params that will be added to the `add_column` call if the migration is reversed. Neat.
