---
title: Using NOT in Postgres CHECK constraints
date: 2021-04-16
published: 2021-04-16
tags: ["postgres"]
is_post: true
---

## Using NOT in Postgres CHECK constraints
For some reason I could not find good information on this (maybe because it's obvious). But you can simply add a `NOT` into your Postgres `CHECK CONSTRAINTS`. Consider the following scenario: 

You have a table that contains pricing data and that data has both a frequency (monthly, daily, etc) and a value in cents. That table may look something like:
```sql

CREATE TABLE pricing_data (
    service_name character varying,
    pricing_frequency character varying,
    pricing_value integer
);

```

And when allowing users to edit this information, you don't want to FORCE them to input that info every time the save it thus adding a `NOT NULL` constraint is out of the picture. On the other hand, if a user inputs ONE of the pricing values, you want to be sure that the OTHER value is also present. After messing around a bit, I wrote a constraint that validated if both or neither values are `NULL`:

```sql
ALTER TABLE pricing_data
ADD CONSTRAINT require_pricing_frequency_and_pricing_value CHECK (
    num_nulls(pricing_frequency, pricing_value) = 1
)
```

This is the opposite of what we actually want. After ~30 mins of searching the internet and finding NOTHING helpful about the "opposite of a `CHECK CONSTRAINT` (though I did learn about [`EXCLUDE` constraints](https://www.postgresql.org/docs/9.0/sql-createtable.html#SQL-CREATETABLE-EXCLUDE)) I tried simply throwing a `NOT` in my constraint to see what it would do

```sql
ALTER TABLE pricing_data
ADD CONSTRAINT require_pricing_frequency_and_pricing_value CHECK (
    NOT (num_nulls(pricing_frequency, pricing_value) = 1)
)
```

Lo-and-behold, this did what I wanted and I was able to leverage the DB to validate my data!