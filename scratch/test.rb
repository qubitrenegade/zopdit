#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default
require 'zopdit'

client_id, secret, username, password = %w[
  ZOP_CLIENT_ID
  ZOP_SECRET
  ZOP_USERNAME
  ZOP_PASSWORD
].map { |s| ENV[s] }

puts "Clientid: #{client_id}"

module Zopdit
end

# me = zrc.client.get '/api/v1/me/karma'
zop = Zopdit::Bot.new(
  reddit_username: username,
  reddit_password: password,
  reddit_client_id: client_id,
  reddit_secret: secret,
  subreddit: 'u_zop_bot'
)

me = zop.reddit.karma
puts me

zop.update_post_db
zop.posts.un_update_posted 12

__END__
puts "Post id 12: #{zop.posts.ds.where(id: 12)[:id]}"
a = zop.posts.ds.where(id: 12)[0]
puts "a.class: #{a.class}"

# puts zrc.post
# post = zrc.post subreddit: 'u_zop_bot', title: 'Test Post Please Ignore', url: 'https://qubitrenegade.com'
# puts zrc.comment("this is a test comment\n\n[this is a test link](https://qubitrenegade.com)\n\nthis is a final line", post.name)
# rubocop:enable Metrics/LineLength
__END__
# me = zrc.client.get '/api/vi/me'
# me = authed.get '/api/v1/me'

# puts me.status
# puts me.body

con = Faraday::Connection.new REDDIT_BASE_URL
con.headers['User-Agent'] = USER_AGENT
con.basic_auth client_id, secret

# %w[client_id client_secret username password grant_type].each do |type|
#   puts "#{type}: #{options[type.to_sym]}"
# end

# zrc = Zopdit::Reddit::Client.new
# con = zrc.auth_client
# con = Zopdit::connection

response = con.post('/api/v1/access_token', options)
raise "Error Code: #{response.status}" unless response.success?
req_time = Time.now
resp = response.body.then { |s| JSON.parse s, object_class: OpenStruct }
  .then { |s| s.time_set = req_time; s.expires = s.time_set + s.expires_in; s }
# resp = response.body.then { |s| JSON.parse s, object_class: OpenStruct }
#   .then { |s| s['time_set'] = req_time; s }
#   .then { |s| s.expires = s.time_set + s.expires_in; s oo
# resp = JSON.parse(response.body, object_class: OpenStruct)
# resp['time_set'] = req_time
# resp.expires = resp.time_set + resp.expires_in
access_token = resp.access_token

puts response.body
puts resp
puts "Access token: #{access_token}"

# authed = Zopdit::connection
# con.headers['Authorizeation'] = "BEARER #{access_token}"
authed = Faraday::Connection.new REDDIT_BASE_URL
authed.headers['User-Agent'] = USER_AGENT
# authed.headers['Authorizeation'] = "BEARER #{access_token}"
# authed.headers['Authorization'] = "bearer #{access_token}"
authed.basic_auth client_id, secret

me = authed.get '/api/v1/me'

puts me.status
puts me.body


__END__
response = Faraday.get Zopdit.url
feed = RSS::Parser.parse response.body

puts "Title #{feed.channel.title}"
# z = feed.items.first.then { |s| Zopdit::RSS::Item.new s }
# z.print_item

def skip_item(title)
  puts "#{title} Does not have direct_link"
end

feed.items.each do |item|
  z = Zopdit::RSS::Item.new item
  next skip_item(z.title) unless z.direct_link

  z.print_item
end
