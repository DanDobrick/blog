require 'date'
require 'fileutils'

class Draft < Thor
  def self.exit_on_failure?
    true
  end

  no_commands do
    def titleize(string)
      string.gsub(/\b(?<!\w['â`])[a-z]/) { |match| match.capitalize }
    end
  end

  desc 'create TITLE', 'Creates a new draft in the drafts folder'
  method_option :tags, aliases: '-t', desc: 'Adds tags', type: :array, default: []
  method_option :categories, aliases: '-c', desc: 'Adds categories', type: :array
  method_option :github, aliases: '-g', desc: 'Github link', type: :string
  method_option :no_image, desc: 'Used for the "no_image" front matter', type: :boolean, default: false
  def create(title)
    today = ::Date.today

    file_name = "#{today}-#{title.downcase.gsub(' ', '-')}.md"
    tags = options[:tags]
    category_string = options[:categories] ? "categories: #{options[:categories]}" : ''
    no_image_string = options[:no_image] ? "no_image: #{options[:no_image]}" : ''
    github_string = options[:github] ? "github: #{options[:github]}" : ''
    flag_options = [category_string, no_image_string, github_string]

    titleized_title = titleize(title)

    draft = <<-DRAFT
---
title: #{titleized_title}
date: #{today}
published: #{today}
tags: #{tags}
is_post: true#{flag_options.compact.join("\n")}
excerpt: this is an optional excerpt that has priority over the first paragraph.
---
This paragraph will be used as the excerpt if you don't have an "excerpt" front matter. Also if you don't use the "more" below, the index will take the first paragraph as the excerpt

As a note, you might need to edit the title both in the front-matter and in the header below. This script will capitalize words like "is" and "or"
<!--more-->

## #{titleized_title}
DRAFT

    file = File.open("./_drafts/#{file_name}", 'w') { |f| f.write(draft) }
    puts "Draft '#{file_name}' created"
  end

  desc 'publish', 'Publishes file from the drafts folder'
  def publish
    files = Dir['./_drafts/*'].reject do |file|
      file == './_drafts/draft.md'
    end

    puts "Choose a post to publish using the numbers beside the file names:"
    files.each_with_index do |file, i|
      puts "#{i}. #{file[10..-1]}"
    end

    selection = STDIN.gets.chomp
    post_to_move_with_path = files[selection.to_i]
    post_to_move = files[selection.to_i][10..-1]

    puts "Publish #{post_to_move}? (y/n)"
    response = STDIN.gets.chomp
    exit unless response == 'y'

    new_location = "./_posts/#{post_to_move}"
    FileUtils.mv(post_to_move_with_path, new_location)
    puts "Moved #{post_to_move_with_path} to #{new_location}"

    puts "Deploy now?\nWARNING: This will also deploy any other changes to the repo as well."
    response = STDIN.gets.chomp

    if response == 'y'
      parts =  post_to_move.split('-')
      parts.shift(3)
      parts.last.gsub!('.md', '')
      new_post_title = titleize(parts.join(' '))

      system('git add .')
      system("git commit -m \"Publish new post: \'#{new_post_title}\'\"")
      system('git push origin')

      puts "Published #{new_post_title}."
    end
  end
end
