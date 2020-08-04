---
title: Postgres Lateral Join
date: 2020-08-04
published: 2020-08-04
tags: [postgres, optimization]
is_post: true
---
During some query optimization work one of my co-workers made a PR that used PostgreSQL's `LATERAL JOIN` which is a feature that I've not seen before.

Postgres introduced `LATERAL JOIN` in [PosgreSQL 9.3](https://www.postgresql.org/about/news/1481/) with an innocuous sentence in the [release notes](https://www.postgresql.org/docs/9.3/release-9-3.html):

> Implement SQL-standard [`LATERAL`](https://www.postgresql.org/docs/9.3/queries-table-expressions.html#QUERIES-LATERAL) option for FROM-clause subqueries and function calls

Cool... But for those of us who don't know the whole SQL-standard, we need more information to understand what `LATERAL JOIN`s are, how to use them and what benefits they provide.

<!--more-->

## What is `LATERAL JOIN`?
The Postgres docs have an explanation of what `LATERAL JOIN` is:

>When a FROM item contains LATERAL cross-references, evaluation proceeds as follows: for each row of the FROM item providing the cross-referenced column(s), or set of rows of multiple FROM items providing the columns, the LATERAL item is evaluated using that row or row set's values of the columns. The resulting row(s) are joined as usual with the rows they were computed from. This is repeated for each row or set of rows from the column source table(s).

But, like most postgres docs, this is pretty dense and difficult to parse. The way I understand `LATERAL JOIN`  is to read 
https://heap.io/blog/engineering/postgresqls-powerful-new-join-type-lateral

and summarize here

## How to Use

Example given by postgres:
```sql
SELECT * FROM foo, LATERAL (SELECT * FROM bar WHERE bar.id = foo.bar_id) ss;
```

## Why Bother?

>  with the LATERAL join keyword we can reference the orders table in a subselect query which is not possible with standard joins.