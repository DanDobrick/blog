---
title: Cancelling PostgreSQL Queries When HTTP Request Times Out
date: 2020-08-04
published: 2020-08-04
tags: ['postgres', 'rails', 'active-record']
is_post: true
excerpt: this is an optional excerpt that has priority over the first paragraph.
---
During a recent effort at work to optimize database performance we found a bunch of queries which our Rails application triggered but, since the query took longer than our configured HTTP timeout, the transaction was later abandoned. We had initially thought that [PgBouncer](https://github.com/pgbouncer/pgbouncer) might have a setting to cancel queries after a request times-out, but [that doesn't seem to be a feature](https://github.com/pgbouncer/pgbouncer/issues/63) that PgBouncer Currently supports.

We want to cancel these queries to free-up database resources, especially in case we have db bottlenecks.

<!--more-->

## Options For Stopping a Long-Running Query

PostgreSQL supports [various methods](https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADMIN-SIGNAL) of cancelling queries that are currently running, but each of these requires the id of the currently running process:

Table below was copied from Postgres Docs found in the link above.

{: .table .table-striped}
Function | Description
--------- | -----------
`pg_cancel_backend(pid int)` | Cancel a backend's current query.
`pg_terminate_backend(pid int)` | Terminate a backend.

Unfortunately knowing the `pid` of the running query will require even more db calls during a time when we're trying to minimize use of db resources.

## Maybe We Can Use PgBouncer Settings

![PgBouncer diagram]({{ site.baseurl }}/assets/images/{{ page.id }}/pg-bouncer.png)

I found a [feature request](https://github.com/pgbouncer/pgbouncer/issues/63) on PgBouncer's github for this exact scenario, and the consensus here (as well as elsewhere on the internet) was that the application should be the one controlling when Postgres gives up on a transaction using Postgres' `statement_timeout`. There are a couple ways to set this value but, until PgBouncer implements a new feature, we will have to do this in Postgres itself.


## My Preferred Solution
The [PG docs](https://www.postgresql.org/docs/9.6/runtime-config-client.html) state that setting a `statement_timeout` will
> Abort any statement that takes more than the specified number of milliseconds, starting from the time the command arrives at the server from the client

It's not recommended to set this globally since it will affect all sessions though you'll find many examples of people simply updating their database.yaml to look like:

```yaml
production:
   url: <%= DATABASE_URL %>
   variables:
     statement_timeout: 45000
```

This is not something we want in our database since we make extensive use of background jobs that take longer than our configured HTTP timeout value and this would prevent them from completing!

Luckily we have other options!
1) Executing `SET LOCAL statement_timeout = 45000` on every request coming from the Rails App, leaving requests coming from background jobs without a `statement_timeout` value.
2) Setting a statement_timeout for particular DB users via `ALTER ROLE rails_user SET statement_timeout = 45000`

I strongly prefer doing #2 since adding another statement to each rails request, but then preventing it from happening on each background job that _uses_ the rails code would be a nightmare.

We simply need to create multiple DB users for the various ways we interact with the database, setting timeouts accordingly. We can then manually increase this value in application code for any queries we need to run longer than whatever we set the limit to!
