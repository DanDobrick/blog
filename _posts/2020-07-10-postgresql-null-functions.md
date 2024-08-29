---
title: "PostgreSQL `num_nulls` and `num_nonnulls`"
date: 2020-07-10
published: 2020-07-10
comments: true
categories: software
tags: [postgres, rails, ruby, active-record]
is_post: true
excerpt: PostgreSQL offers a few comparison functions that are very useful if your table has columns that require exactly one entry. I ran into a situation recently that utilized the `num_nonnulls` function combined with a DB constraint to ensure that only one of a group of tables had data.
---
![Postgres Logo]({{ site.baseurl }}/assets/images/{{ page.id }}/postgres.png)

PostgreSQL offers a few comparison functions that are very useful if your table has columns that require exactly one entry. I ran into a situation recently that utilized the `num_nonnulls` function combined with a DB constraint to ensure that only one of a group of tables had data.
<!--more-->

## Problem
The table I was designing looked something like this:

{: .table .table-striped}
Column name | Data type | Notes
----------- | --------- | -----
`bool_response` | boolean | Must be null if there is a value in any other `*_response` columns
`int_response` | integer | Must be null if there is a value in any other `*_response` columns
`text_response` | text | Must be null if there is a value in any other `*_response` columns

We want each row in this table to only have ONE non-null value in any `*_response` column, and I wanted to implement a DB constraint on top of the application-level validation to catch any race conditions (such as multiple entries being
saved to the DB at the same time).

## Solution
Luckily I am using Postgres as our database which provides a [couple comparison functions](https://www.postgresql.org/docs/10/functions-comparison.html#FUNCTIONS-COMPARISON-FUNC-TABLE) that count the number of nulls in a set of columns: `num_nonnulls` and `num_nulls`.

This table from the documentation linked above explains the two functions:

{: .table .table-striped}
Function | Description | Example | Example Result
-------- | ----------- | ------- | --------------
num_nonnulls(VARIADIC "any") | returns the number of `non-null` arguments | num_nonnulls(1, NULL, 2) | 2
num_nulls(VARIADIC "any") | returns the number of `null` arguments | num_nulls(1, NULL, 2) | 1

I decided to use the first function (`num_nonnulls`), adding a constraint that checks those columns and ensure there is only a single non-null value:

```sql
ALTER TABLE my_example_table
    ADD CONSTRAINT only_one_non_null_response
    CHECK (num_nonnulls(bool_response, int_response, text_response) = 1);
```

Finally I paired this with an app-level validation (this project is using Rails aActiveRecord):

```ruby
class MyResponseClass < ActiveRecord::Base
  validate :only_one_response
  # ...
  def only_one_response
    if non_null_responses.count != 1
      non_null_responses = [bool_response, int_response, text_response].compact 
    end

    errors.add(:base, "Must only have a single response" )
  end
end
```
