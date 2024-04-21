---
title: ActiveRecord `take` vs `first`
date: 2024-04-08
published: 2024-04-08
tags: [ruby, postgres, rails, active-record]
is_post: true
---
ActiveRecord has a method called `take` that returns a single record similar to `first`, except `take` doesn’t order the records before selecting one. This can GREATLY increase performance in some circumstances; the latency graph above shows a real-life example of `take` significantly reducing the duration of an api call by changing a single `first` to `take`.
<!--more-->

## ActiveRecord's `first` method
I was working in a controller that had some code similar to the following where we wanted to get a single record that matched a `where` clause, then perform a function on that record. It didn't matter _which_ record we grabbed, only that this record matched our `where` clause.

```ruby
user = User.where(last_name: 'Dobrick').first
MyService.action(user)
```

Unbeknownst to me, ActiveRecord's `first` method appends an `ORDER` clause to the sql before adding a `LIMIT 1`

```sql
SELECT  "users".* FROM "users" WHERE "users"."last_name" = 'Dobrick' ORDER BY "users"."id" ASC LIMIT 1
```

This means that your database will first need to find all the rows that match our `where` clause, then order them before returning one of the records. Depending on how many records match your `where` clause, the `order` could take longer than expected, just to return the single record you wanted.


## `take` to the rescue
Luckily, I stumbled upon [this StackOverflow](https://stackoverflow.com/questions/18496421/take-vs-first-performance-in-ruby-on-rails/18498255#18498255) answer that mentioned `take` as a faster alternative.

The exact same code using `take` instead of `first`:

```ruby
user = User.where(last_name: 'Dobrick').take
MyService.action(user)
```

Gives the same query without the `ORDER BY` clause:
```sql
SELECT  "users".* FROM "users" WHERE "users"."last_name" = 'Dobrick' LIMIT 1
```

This means our datbase can stop once it finds a single record and return it to us, rather than spend extra time and cycles ordering a bunch of records we don't care about.

I'm going to show the header image for this post once more to show how big of an impact a single change had on a production API call; you can see the exact deploy where this change was made reducing the average latency from ~200ms to ~0.02ms.
![Latency Graph]({{ site.baseurl }}/assets/images/{{ page.id }}/new-relic.png){: .img-responsive}

## Other Options
As the answer on StackOverflow mentioned, you can use something like `find_by` to achieve the same result

```ruby
user = User.find_by(last_name: 'Dobrick')
MyService.action(user)
```

and while this works in our contrived example here, sometimes that's not an option in a real-world application, so having `take` in your toolbag can be quite handy.