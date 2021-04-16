---
title: Using NOT in Postgres CHECK constraints
date: 2021-04-16
published: 2021-04-16
tags: ["postgres"]
is_post: true
---
For some reason I could not find good information on this (maybe because it's obvious). But you can add `NOT` into your Postgres `CHECK CONSTRAINT`s. This is particularly useful when you find a nice succinct way to express the opposite condition of the constraint you want.
<!--more-->

## Using NOT in Postgres CHECK constraints
Consider the following scenario:

You have a table that contains pricing data and that data has both a frequency (monthly, daily, etc) and a value in cents. That table may look something like:
```sql

CREATE TABLE pricing_data (
    service_name character varying,
    pricing_frequency character varying,
    pricing_value integer
);

```

When allowing users to edit this information, we don't want to require that info when creating the record thus adding a `NOT NULL` constraint is out of the picture. On the other hand, if a user inputs ONE of the pricing values, you want to be sure that the OTHER value is also present.

A constraint such as this would work
```sql
ALTER TABLE pricing_data
ADD CONSTRAINT require_pricing_frequency_and_pricing_value CHECK (
    (num_nulls(pricing_frequncy, pricing_value) == 0)
    OR
    (num_nulls(pricing_frequncy, pricing_value) == 2)
)
```

But that was a bit verbose and I knew there must be a better way; after messing around a bit, I wrote a constraint that validated if both or neither values are `NULL`:

```sql
ALTER TABLE pricing_data
ADD CONSTRAINT require_pricing_frequency_and_pricing_value CHECK (
    num_nulls(pricing_frequency, pricing_value) = 1
)
```

Unfortunately, this is the opposite of what we actually want.

After searching the internet and finding nothing helpful (though I did learn about [`EXCLUDE` constraints](https://www.postgresql.org/docs/9.0/sql-createtable.html#SQL-CREATETABLE-EXCLUDE)) I tried simply throwing a `NOT` in my constraint to see what it would do

```sql
ALTER TABLE pricing_data
ADD CONSTRAINT require_pricing_frequency_and_pricing_value CHECK (
    NOT (num_nulls(pricing_frequency, pricing_value) = 1)
)
```

Lo-and-behold, this did what I wanted and I was able to leverage the DB to validate my data! Huzzah!