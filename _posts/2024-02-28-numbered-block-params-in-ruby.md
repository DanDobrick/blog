---
title: Numbered Block Params In Ruby
date: 2024-02-28
published: 2024-02-28
tags: [ruby]
is_post: true

excerpt: Ruby 2.7 added some syntax sugar that has been making my life easier at work; no longer do I need to use `a` as my "placeholder" variable in enumerators, instead, we have a built in "numbered" block parameter!
---
## Numbered Block Params In Ruby

I came across [this article](https://zverok.space/blog/2023-10-11-syntax-sugar1-numeric-block-args.html) the a few months back about a little piece of ruby syntax that has become something I reach for on a regular basis.

Let’s for example say we had an array of students, I'll represent them here as `OpenStruct`s:

```ruby
students = [
  OpenStruct.new(first_name: 'Dan', last_name: 'Dobrick', location: 'CO'),
  OpenStruct.new(first_name: 'Bryce', last_name: 'Harper', location: 'PA'),
  OpenStruct.new(first_name: 'Sean', last_name: "Villanueva O'Driscoll", location: 'Belgium')
]
```

It's pretty easy to get data about each object in the array, for example, we could `map` across the students and get all their first names:

```ruby
> students.map { |student| student.first_name }
=> ["Dan", "Bryce", "Sean"]
```

And since engineers are lazy and Ruby likes giving you a thousand ways of doing the same thing, of course we have a shorthand for this.


```ruby
> students.map(&:first_name)
=> ["Dan", "Bryce", "Sean"]
```

Unfortunately, if you want to do anything more complex than calling a method on the object, you still need to use the longer syntax and declare a variable.

```ruby
> students.map { |student| "#{student.first_name} #{student.last_name}" }
=> ["Dan Dobrick", "Bryce Harper", "Sean Villanueva O'Driscoll"]
> students.map { |student| SomeService.action(student) }
=> [{:name=>"Dan Dobrick", :location=>"CO"},
 {:name=>"Bryce Harper", :location=>"PA"},
 {:name=>"Sean Villanueva O'Driscoll", :location=>"Belgium"}]
```

This kind gets annoying when you have long variable names. The following is something copied from a production codebase I've worked on, but tweaked enough to make it more anonymized (and in fact a bit shorter)

```ruby
student_subject_observations.map { |student_subject_observation| SomeService.record_observation(student_subject_observation) }
```

If you wanted to keep the variable names for whatever reason you would likely refactor this to use the `do/end` synax instead

```ruby
student_subject_observations.map do |student_subject_observation|
  SomeService.record_observation(student_subject_observation)
end
```

While sorta readable, this can be a pain to type out (and like I said above, engineers are a lazy bunch) so maybe you'd use abbreviations

```ruby
student_subject_observations.map { |sso| SomeService.record_observation(sso) }
```

but if you start using short variable names everywhere, things may get a bit confusing.

Luckily Ruby 2.7 gives us yet ANOTHER way of declaring the iterator variable within a block that removes the need to think of a variable name or type as much: [Numbered block parameters](https://rubyreferences.github.io/rubychanges/2.7.html#numbered-block-parameters). 

We can refactor the long string of `student_observation_milestone` above into something a bit shorter:

```ruby
student_observation_milestones.map { SomeService.record_observation(_1) }
```

where the `_1` references the first param that was passed into `map` and the subsequent numbers(`_2`, `_3`, etc) correspond to the 2nd, 3rd, etc params. This means you don't have to use `_` for unused params:

```ruby
> double_array = [['first item', 'second item'], ['1st item', '2nd item']]
=> [["first item", "second item"], ["1st item", "2nd item"]]
> double_array.map { |_, second| "The item is: #{second}" }
=> ["The item is: second item", "The item is: 2nd item"]
> double_array.map { "The item is: #{_2}" }
=> ["The item is: second item", "The item is: 2nd item"]
```

And a contrived example of an even larger numbered param:

```ruby
> other_double_array = [[0, 1, 2, 4, 5, 6, 7], ['a', 'b', 'c', 'd', 'e', 'f']]
=> [[0, 1, 2, 4, 5, 6, 7], ["a", "b", "c", "d", "e", "f"]]
> other_double_array.map { _5 }
=> [5, "e"]
```

This has come in _super_ handy when debugging. No longer do I need to use `a` as my variable name when looking for a value:
```ruby
foo.map { |a| a.first_name == "Homer" }
# Becomes
foo.map { _1.first_name == "Homer" }
```

and my workplace has actually started to adopt this syntax in our codebases for short blocks where explicit variable names aren't adding to the understanding of the code.
