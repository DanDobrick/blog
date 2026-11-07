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

    File.open("./_drafts/#{file_name}", 'w') { |f| f.write(draft) }
    puts "Draft '#{file_name}' created"
  end

  desc 'photo TITLE PHOTO_PATH', 'Creates a photo-only draft from an image file (converted to JPEG, resized, saved as top.jpg plus a square thumb.jpg)'
  method_option :tags, aliases: '-t', desc: 'Adds tags', type: :array, default: ['photo']
  method_option :max_width, aliases: '-w', desc: 'Max width/height in pixels for the longest side', type: :numeric, default: 2000
  method_option :focus, aliases: '-f', desc: 'Vertical focus of the home page banner crop, 0 (top) to 100 (bottom). Default: auto-detected', type: :numeric
  method_option :quality, aliases: '-q', desc: 'JPEG quality (1-100)', type: :numeric, default: 85
  def photo(title, photo_path)
    source = File.expand_path(photo_path)
    abort "Photo not found: #{source}" unless File.file?(source)
    abort "This command needs macOS's `sips` tool." unless system('which sips > /dev/null 2>&1')

    today = ::Date.today
    slug = title.downcase.gsub(' ', '-')
    file_name = "#{today}-#{slug}.md"
    titleized_title = titleize(title)
    dir = "./assets/images/posts/#{slug}"
    dest = "#{dir}/top.jpg"
    abort "#{dest} already exists; pick a different title." if File.exist?(dest)

    # Convert whatever we were given (HEIC, PNG, JPG...) to JPEG, shrinking
    # only if the longest side is bigger than max_width.
    FileUtils.mkdir_p(dir)
    dims = `sips -g pixelWidth -g pixelHeight "#{source}"`.scan(/pixel(?:Width|Height): (\d+)/).flatten.map(&:to_i)
    args = ['-s', 'format', 'jpeg', '-s', 'formatOptions', options[:quality].to_s]
    args += ['--resampleHeightWidthMax', options[:max_width].to_s] if dims.max.to_i > options[:max_width]
    ok = system('sips', *args, source, '--out', dest, out: File::NULL)
    abort 'Image conversion failed' unless ok

    # Square, center-cropped thumbnail for the home page feed and /photos/ grid.
    out_dims = `sips -g pixelWidth -g pixelHeight "#{dest}"`.scan(/pixel(?:Width|Height): (\d+)/).flatten.map(&:to_i)
    side = out_dims.min
    thumb_size = [side, 600].min
    thumb = "#{dir}/thumb.jpg"
    thumb_ok = system('sips', '-c', side.to_s, side.to_s, dest, '--out', thumb, out: File::NULL) &&
               system('sips', '--resampleHeightWidth', thumb_size.to_s, thumb_size.to_s,
                      '-s', 'formatOptions', '80', thumb, out: File::NULL)
    abort 'Thumbnail creation failed' unless thumb_ok

    focus = options[:focus]
    if focus.nil?
      puts 'Detecting the interesting part of the photo (first run takes a few seconds)...'
      detected = `swift #{File.expand_path('scripts/focus.swift', __dir__)} "#{dest}" 2>/dev/null`.strip
      focus = detected =~ /\A\d+\z/ ? detected.to_i : 50
    end
    focus = focus.to_i.clamp(0, 100)

    draft = <<-DRAFT
---
title: #{titleized_title}
date: #{today}
published: #{today}
tags: #{options[:tags]}
is_post: true
photo: true
photo_focus: #{focus}%
excerpt: ""
---
<!-- Optional one-line caption goes here. Delete this comment (and leave the body empty) for a photo-only post. -->
DRAFT

    File.open("./_drafts/#{file_name}", 'w') { |f| f.write(draft) }
    puts "Draft '#{file_name}' created"
    puts "Photo saved to #{dest} (+ thumb.jpg), banner focus #{focus}% (edit photo_focus in the draft to adjust)"
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
      parts = post_to_move.split('-')
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
