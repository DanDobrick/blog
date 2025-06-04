---
title: "Postgres Enums: Don't Use 'Em"
date: 2022-04-22
published: 2022-04-22
tags: [postgres, enums, database]
is_post: true

excerpt: "While Postgres offers an ENUM type, the general recommendation is NOT to use it, here I discuss why and give an alterative solution that I prefer: creating a new table and referencing foreign keys"
---

When designing a table with a column that will only select from a limited number of options, you'll want to ensure that the values in your database match whatever options you lay out. For example, we could have a table of subscriptions that have either a `monthly` or `annual` recurrence interval:

```sql
CREATE TABLE subscriptions(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  cost_cents INTEGER CHECK(cost_cents > 0),
  recurrence_interval VARCHAR -- Need to ensure the values of this column are consistent
);
```

There are a few options for doing this in postgres, but I'm only going to discuss to here, one I recommend (a new table) and one I do not (using `ENUM`s)

## Postgres Enum Type
Postgres gives you fairly easy to create and access ENUMs:

```sql
CREATE TYPE INTERVAL_OPTIONS as ENUM ('monthly', 'annual');

CREATE TABLE subscriptions(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  cost_cents INTEGER CHECK(cost_cents > 0),
  recurrence_interval INTERVAL_OPTIONS
);
```

Postgres will check the values you insert to ensure they're included in the enum and raise an error if they're not valid:

```sql
INSERT INTO subscriptions (cost_cents, recurrence_interval)
VALUES(100, 'not-enumerated');
-- ERROR:  invalid input value for enum interval_options: "not-enumerated"
-- LINE 2: VALUES(100, 'not-enumerated');
```

While it's easy to insert [new values into the enum](https://www.postgresql.org/docs/current/sql-altertype.html) (after postgres 9.1)

```sql
ALTER TYPE INTERVAL_OPTIONS ADD VALUE 'bi-annual'; -- appends to list
```
Dropping a value is [not supported](https://www.postgresql.org/docs/current/datatype-enum.html)!

> Although enum types are primarily intended for static sets of values, there is support for adding new values to an existing enum type, and for renaming values (see [ALTER TYPE](https://www.postgresql.org/docs/current/sql-altertype.html)). Existing values cannot be removed from an enum type, nor can the sort ordering of such values be changed, short of dropping and re-creating the enum type.

As for why, Tom Lane (a member of the core postgres development team) states the following [a mailing list post from 2018](https://www.postgresql.org/message-id/835.1527628154%40sss.pgh.pa.us)


> The key problem that is hard to fix here is that, even if today you have
no live rows containing that value, it may still be present in indexes.
In a btree, for example, the value might've migrated up into upper index
pages as a page boundary value.  Once that's happened, it's likely to
persist indefinitely, even if the live occurrences in the underlying table
get deleted and vacuumed away.

It's the lack of removing elements from the Enum that makes them a _bad_ candidate for most use-cases; unless you KNOW FOR CERTAIN that you'll never need to _remove_ an element from the enum, I suggest creating a new table and using foreign key relationships to accomplish a similar goal.

## New Table and Foreign Keys
Creating a table to store the values and referencing them is a _very_ similar process to creating the `ENUM`.

```sql
CREATE table recurrence_intervals(
  id VARCHAR PRIMARY KEY
);

CREATE TABLE subscriptions(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  cost_cents INTEGER CHECK(cost_cents > 0),
  recurrence_interval VARCHAR,
  CONSTRAINT fk_recurrence_interval
    FOREIGN KEY(recurrence_interval) 
      REFERENCES recurrence_intervals(id)
);
```
Then adding new values is a simple INSERT into the DB

```sql
INSERT INTO recurrence_intervals(id) value ('bi-annual')
```

and you still have referential integrity

```sql
INSERT INTO subscriptions (cost_cents, recurrence_interval)
VALUES(100, 'not-enumerated');
-- ERROR:  insert or update on table "subscriptions" violates foreign key constraint "fk_recurrence_interval"
-- DETAIL:  Key (recurrence_interval)=(not-enumerated) is not present in table "recurrence_intervals".
```

And while [JOINS are VERY cheap](https://www.brianlikespostgres.com/cost-of-a-join.html), if we use descriptive strings for the primary keys we don't have to do any JOINS to get the data we want.

```sql
SELECT * from subscriptions LIMIT 1
--                   id                  | cost_cents | recurrence_interval 
--------------------------------------+------------+---------------------
 -- 855418d0-ae44-4e44-ba7c-dab24370dc1e |        100 | monthly
```

Finally, you can _remove_ a value from the table by ensuring there are no references then simply dropping the value:

```sql
DELETE FROM recurrence_intervals where id='monthly'
```
While this is TECHINICALLY possible with ENUMs, the quote from Tom Lane above explains why it's a bad idea.

## Conclusion
And it's for all of these reasons that I recommend using a new table and FK relationships over using the native `ENUM` functionality of Postgres. There are other solutions out there such as storing a string with a `CHECK` constraint or just using in-app validations, but those have the same or _more_ downsides as `ENUM`.