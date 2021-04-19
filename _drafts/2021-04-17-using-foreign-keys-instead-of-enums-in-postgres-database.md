---
title: Using Foreign Keys Instead Of Enums In Postgres Database
date: 2021-04-17
published: 2021-04-17
tags: ['postgres', 'schema', 'enums', 'foreign-keys']
is_post: true
---
When building out a table schema for a data model that can be limited to certain values (this sentence sucks, fix it), there aree a couple options for limiting the values of said field (this sentence also sucks)
<!--more-->

## Using Foreign Keys Instead Of Enums In Postgres Database


There are 4 different ways to handle db columns that can be one of a set number of values:

    Storing strings and doing application validation to ensure our string values are one of the valid options.

        Makes it very easy to add new values

        Removing a value would require a code change + data migration

        Keeps possible values in-code

        Data integrity is only as good as your application’s validations (and there are ways to get around these)

    Creating a new PG data type as an enum

        Very easy to add new values

        Removing values requires you to alter the enum, create a new one, do a data migration then drop the old enum

            Lots of people on The Internet™ say to stay away from enums due to this.

        Solid data integrity

    Storing strings and having a CHECK constraint

        Adding new values requires dropping the check constraint, then re-adding it

        Removing values requires dropping the check constraint, then re-adding it

        Data integrity UNLESS something weird happens between dropping and re-adding the constraint

    Creating new tables and referencing descriptive strings as foreign keys instead of UUIDs

        Adding new values is a simple INSERT into the DB

        Removing old values would require a data migration, then removing that value from the DB

        Data integrity

        Using descriptive strings (such as no_waitlist) for the PKs allows us to forego any JOINs to see the actual values.

        No need to maintain a bunch of validation logic.