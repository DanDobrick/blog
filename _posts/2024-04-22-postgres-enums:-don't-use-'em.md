---
title: "Postgres Enums: Don't Use 'Em"
date: 2024-04-22
published: 2024-04-22
tags: [postgres, enums, database]
is_post: true

excerpt: this is an optional excerpt that has priority over the first paragraph.
---
TODO:

- write an exerpt
- fix anchors (maybe sitewide?)
- Add image
- finish writing other solutions
- Possibly move up the final example
- re-read the whole thing and edit.
- Add anchor links to the numbered list below.
- Consdier changing the way quotes look

This paragraph will be used as the excerpt if you don't have an "excerpt" front matter. Also if you don't use the "more" below, the index will take the first paragraph as the excerpt

As a note, you might need to edit the title both in the front-matter and in the header below. This script will capitalize words like "is" and "or"
<!--more-->

# Postgres Enums: Don't Use 'Em
Consider removing this heading
When designing a table with a column that will only select from a limited number of options, you'll want to ensure that the values in your database match whatever options you lay out. For example, we could have a table of subscriptions that have either a `monthly` or `annual` recurrence interval:

```sql
CREATE TABLE subscriptions(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  cost_cents INTEGER CHECK(cost_cents > 0),
  recurrence_interval VARCHAR -- Need to ensure the values of this column are consistent
);
```

And we have a few options for ensuring the integrity of the data in that column:

1. Postgres Enum Type
2. Creating a new table with descriptive strings and creating FK relationships
3. Storing string with a `CHECK` constraint
4. Storing strings(or integers) with application-level validations

## Postgres Enum Type
Postgres gives you a fairly easy to create and use ENUMs:

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
Creating a table to store the values and referencing them is a _very_ similar process to creating the enum

```sql
CREATE table recurrence_intervals(
  id VARCHAR PRIMARY KEY
)

CREATE TABLE subscriptions(
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  cost_cents INTEGER CHECK(cost_cents > 0),
  recurrence_interval VARCHAR
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

  Removing old values would require a data migration, then removing that value from the DB

  strong Data integrity

  Using descriptive strings for the PKs allows us to forego any JOINs to see the actual values.

  No need to maintain a bunch of validation logic.


## Relying on Application-Level Validations
Another (less-than-ideal)
Example

pros
  Makes it very easy to add new values
  Removing a value would require a code change + data migration
  Keeps possible values in-code
Cons
  Data integrity is only as good as your application’s validations (i.e. not reliable.)

## CHECK Constraints
  Adding new values requires dropping the check constraint, then re-adding it

  Removing values requires dropping the check constraint, then re-adding it

  Data integrity UNLESS something weird happens between dropping and re-adding the constraint


## When Using an Enum May Make Sense
If you know FOR SURE that your values will never change, you can create an enum. For example, the last time we changed the months of the year was [almost 500 years ago](https://en.wikipedia.org/wiki/Gregorian_calendar), so you're safe to use enums for the months of the year.

Imagine you needed to store which month it's safe to plant seeds in a specific region
```sql
CREATE TYPE MONTH as ENUM('Januaray', 'Feburary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

CREATE TABLE plants(
  id INTEGER PRIMARY KEY,
  plant_name VARCHAR UNIQUE NOT NULL,
  zone_name VARCHAR NOT NULL,
  month_to_plant MONTH
);
```

Then you can re-use the MONTH type in other tables as-needed.

```sql
CREATE TABLE other_table(
  id INTEGER PRIMARY KEY,
  event_month MONTH
)
```

Though in this specific case, I'd prefer to store it as an integer with some check constraint since other parts of our system will likely expect "month" to be an integer and it helps with any future [internationalization](https://en.wikipedia.org/wiki/Internationalization_and_localization) you may do.

```sql
CREATE TABLE plants(
  id INTEGER PRIMARY KEY,
  plant_name VARCHAR UNIQUE NOT NULL,
  zone_name VARCHAR NOT NULL,
  month_to_plant INTEGER CHECK (month_to_plant BETWEEN 1 and 12)
);
```