---
title: "Ruby's Partition Method: It Does What You Think."
date: 2020-10-03
published: 2020-10-03
tags: [ruby]
is_post: true
---
Ruby has a neat function in `Enumerable` called [partition](https://ruby-doc.org/core-2.5.1/Enumerable.html#method-i-partition) that can split the values in the enumerable into two partitions based arbitrary logic.
<!--more-->

## My problem

I had an array of ActiveRecord models that were being serialized and returned in a specific order:

```ruby
class Section < ActiveRecord::Base
  # TABLE public.sections (
  # id integer NOT NULL,
  # section_type character varying, NOT NULL,
  # created_at timestamp without time zone NOT NULL,
  # updated_at timestamp without time zone NOT NULL
  # )
  has_many :fields
end

class Field < ActiveRecord::Base
  # TABLE public.fields (
  # id integer NOT NULL,
  # created_at timestamp without time zone NOT NULL,
  # updated_at timestamp without time zone NOT NULL
  # )
  belongs_to :section
end
```

That were being serialized based on a bunch of logic earlier in the application:
```ruby
class SerializerClass
  module_function

  def serialize_fields(fields)
    sorted_fields = special_sort(fields)
  end
end
```

I was tasked with placing any fields belonging to sections of type `last` at the _end_ of the serialized list regardless of where they were sorted previously. Also, if there were multiple fields related to sections of type `last`, I needed to ensure they stayed in the order they were sorted into previously.

This might be better illustrated by a simplified example: say we wanted to place all names starting with the letter `A` a the end of this list, ensuring they were in the same order given to us:

```ruby
# Given Input
['Billy', 'Alex', 'Sanjay', 'Anwar', 'Dan']
# Desired output:
['Billy', 'Sanjay', 'Dan', 'Alex', 'Anwar']
```

Unfortunately ruby `delete_if` doesn't return the objects removed, so we need to find them, delete them then put them back on at the end.

```ruby
last_fields = fields.find_by { |field| field.section.section_type == 'last' }

# Required because .delete(*[]) returns an ArgumentError:
if last_fields.count > 0
  fields = fields.delete(*last_fields)
  fields = fields.append(*last_fields)
end
```

This isn't _great_, but it worked until we could get more explicit ordering in the up-stream logic.

A few weeks later I was told we need to add ANOTHER bit of logic putting fields belonging to any `penultimate` sections after everything except those `last` fields.... Also we didn't have time to add the logic upstream where it really belonged.

This gets gross kinda quickly:
```ruby
last_fields = fields.select { |field| field.section.section_type == 'last' }
penultimate_fields = fields.select { |field| field.section.section_type == 'penultimate' }

if last_fields.any?
  fields = fields.delete(*last_fields)

  if penultimate_fields.any?
    fields = fields.delete(*penultimate_fields)
    # Writing this now I'm realizing I could have done array addition at the end instead of using
    # append, but I like my partition solution better anyway 
    fields = fields.append(*penultimate_fields)
  end

  fields = fields.append(*last_fields)
end
```

Sso I decided to check if [`Array`](https://ruby-doc.org/core-2.5.1/Array.html) or [`Enumerable`](https://ruby-doc.org/core-2.5.1/Enumerable.html) had methods I could leverage.

## My Solution

After reading the docs a bit, I found [partition](https://ruby-doc.org/core-2.5.1/Enumerable.html#method-i-partition) return an array of arrays, the first containing everything that returned `true` and the second array containing everything else:

```ruby
[1, 2, 3, 4, 5, 6].partition { |num| num % 2 == 0 }
# => [[2, 4, 6], [1, 3, 5]]
```

You can also assign multiple variables at the same time like so:
```ruby
even, odd = [1, 2, 3, 4, 5, 6].partition { |num| num % 2 == 0 }

p even
# => [2, 4, 6]
p odd
# => [1, 3, 5]
```

Re-writing the code above with partition we can say:
```ruby
last_fields, other_fields = fields.partition { |field| field.section.section_type == 'last' }
penultimate_fields, other_fields = fields.partition { |field| field.section.section_type == 'penultimate' }

ordered_fields = other_fields + penultimate_fields + last_fields
```
Which feels a lot more straight-forward and gives allows us to have a more declarative ordering statement at the end.
