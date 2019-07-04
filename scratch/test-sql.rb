#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default
require 'zopdit'

require 'logger'

# rubocop:disable Lint/UselessAssignment
client_id, secret, username, password = %w[
  ZOP_CLIENT_ID
  ZOP_SECRET
  ZOP_USERNAME
  ZOP_PASSWORD
].map { |s| ENV[s] }
# rubocop:enable Lint/UselessAssignment

puts "Clientid: #{client_id}"

# testing via monkeypatching
module Zopdit
end

rss = Zopdit::RSS::Feed.new
rss.feed

posts = Zopdit::DB::Posts.new
pp posts.latest_post

if posts == rss.items.first
  puts 'All posts are up to date.  Not inserting anything new'
else
  rss.items.reverse_each do |i|
    posts.insert_post(
      title: i.title,
      published: i.published,
      direct_link: i.direct_link,
      post_link: i.post_link,
      short_description: i.short_description
    )
  end
end

__END__

sth = DB[:posts].prepare(:insert, :insert_posts,
  title: :$title,
  published: :$published,
  direct_link: :$direct_link,
  post_link: :$post_link,
  short_description: :$short_description
)

if latest_post && rss.items.first.title == latest_post.title
  puts 'Seems all posts are up to date...'
else
  rss.items.reverse_each do |i|
    DB[:posts].insert(
      title: i.title, 
      published: i.pub_date, 
      direct_link: i.direct_link, 
      post_link: i.post_link,
      short_description: i.short_description
    )
  end
end



__END__

puts Zopdit.root_dir

def db_insert(_db, sth, **options)
  # db.transaction do
  sth.cal(options)
  # sth.call(title: title, published: published, direct_link: direct_link, post_link: post_link, short_description: short_description)
# end
rescue Sequel::UniqueConstraintViolation => e
  puts "I'm sorry Dave, I can't do that... There's already a post with the title: #{title}"
end

def latest_post(db)
  # single query
  # I, [2019-06-28T20:08:44.125083 #23088]  INFO -- : (0.000629s) SELECT * FROM `posts` ORDER BY `published` DESC LIMIT 1
  # puts 'db[:posts].reverse_order(:published).first'
  post = db[:posts].reverse_order(:published)&.first
  post ? Struct.new(*post.keys).new(*post.values) : nil

  # This results in two queries, maybe there's a way to do a "compund" query, but I think even this raw SQL is two queries...
  # select * from posts p where published = (select max(published) from posts);
  # I, [2019-06-28T20:08:44.125361 #23088]  INFO -- : (0.000113s) SELECT max(`published`) AS 'max' FROM `posts` LIMIT 1
  # I, [2019-06-28T20:08:44.125682 #23088]  INFO -- : (0.000170s) SELECT * FROM `posts` WHERE (`published` = '2019-06-26 16:02:19.000000') LIMIT 1
  # db[:posts].max(:published).then { |published| db[:posts].where(published: published).first }

  # puts 'db[:posts].max(:published).then { |published| db[:posts].where(published: published).first }'
  # db[:posts].max(:published).then { |published| db[:posts].where(published: published).first }

  # puts 'db[:posts].where(published: db[:posts].max(:published))'
  # db[:posts].where(published: db[:posts].max(:published)).first

  # db.fetch('SELECT * FROM posts WHERE published = (SELECT max(published) FROM posts) LIMIT 1;').first
end

def post_by_title(db, title)
  post = db[:posts].where(title: title).first
  post ? Struct.new(*post.keys).new(*post.values) : nil
end

DB = File.join(Zopdit.root_dir, 'db', 'test.db').then { |s| Sequel.connect "sqlite://#{s}" }
DB.loggers << Logger.new($stdout)

sth = DB[:posts].prepare(:insert, :insert_posts,
                         title: :$title,
                         published: :$published,
                         direct_link: :$direct_link,
                         post_link: :$post_link,
                         short_description: :$short_description)

latest_post = latest_post(DB)

if latest_post && rss.items.first.title == latest_post.title
  puts 'Seems all posts are up to date...'
else
  rss.items.reverse_each do |i|
    DB[:posts].insert(
      title: i.title, 
      published: i.pub_date, 
      direct_link: i.direct_link, 
      post_link: i.post_link,
      short_description: i.short_description
    )
  end
end

__END__

__END__    
    puts db_insert(DB, sth, {
      title: i.title, 
      published: i.pub_date, 
      direct_link: i.direct_link, 
      post_link: i.post_link,
      short_description: i.short_description
    })
  end
end

latest_post = latest_post(DB)

pp latest_post.title
pp rss.items.first.title

# pp latest_post(DB)
puts "latest_posts(DB).title: #{latest_post(DB).title}"
puts "latest_post(DB)[:title]: #{latest_post(DB)[:title]}"
puts "rss.items.first.title: #{rss.items.first.title}"

pp latest_post DB
pp post_by_title DB, 'Blood: Fresh Supply'

__END__

# Run the migration
# DB.create_table? :posts do
#   primary_key :id
#   String :title, unique: true, index: true
#   DateTime :published, index: true:q!
#   String :direct_link
#   String :post_link
#   String :short_description
# end

rss.items.reverse_each do |i|
  # sth.call(:insert_posts, title: i.title, published: i.pub_date)

  db_insert(DB, sth, i.title, i.pub_date, i.direct_link, i.post_link, i.short_description)
  # db_insert(DB, sth, i.title, i.pub_date, i.direct_link, i.post_link, i.short_description)
  # DB.transaction do
  #   sth.call(title: i.title, published: i.pub_date, direct_link: i.direct_link, post_link: i.post_link, short_description: i.short_description)
  # end

  # begin
  #   DB.transaction do
  #     sth.call(title: i.title, published: i.pub_date, direct_link: i.direct_link, post_link: i.post_link)
  #   end
  # rescue Sequel::UniqueConstraintViolation => msg
  #   puts "I'm sorry Dave, I can't do that... There's already a post with the title: #{i.title}"
  # end
end

pp latest_post DB
pp post_by_title DB, 'Blood: Fresh Supply'
# dset = DB[:posts].reverse_order(:published)
# pp dset.first

# rss.items.first.then do |item|
#   item.print_item

#  puts "Hour: #{item.pub_date.hour}"
# end

# rss.feed.items.first.then { |s| pp s }i