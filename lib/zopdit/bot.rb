# frozen_string_literal: true

module Zopdit
  # This is a test.  This is only a test
  class Bot
    attr_accessor :posts, :rss, :reddit

    def initialize(reddit_username:, reddit_password:, reddit_client_id:, reddit_secret:, subreddit:)
      self.reddit = Zopdit::Reddit::Client.new(
        username: reddit_username,
        password: reddit_password,
        client_id: reddit_client_id,
        secret: reddit_secret,
        subreddit: subreddit
      )
      self.rss = Zopdit::RSS::Feed.new
      self.posts = Zopdit::DB::Posts.new
    end

    def update_post_db
      if posts == rss.items.first
        puts 'Latest post up to date.  Not inserting anything new'
      else
        count = count_new_posts
        puts "Items to insert #{count}"
        rss.items.reverse_each do |item|
          # if there's more than one post we're inserting then we probably don't want to try to post them all
          posts.insert_post item, posted: false, to_post: count <= 1
        end
      end
      post_links
    end

    def count_new_posts
      rss.items.count { |i| !posts.post_by_title i.title }
    end

    def post_links
      posts.links_to_post.tap { |links| puts 'No links to post' unless links.count.positive? }.each do |link|
        post = reddit.post subreddit: 'u_zop_bot', title: link.title, url: link.post_link
        if post.errors.any?
          puts "post.errors.shift #{post.errors.shift}"
        else
          comment = reddit.comment "####{link.short_description}\n\n_Direct:_ #{link.direct_link}", post.data.name
          pp comment
          posts.update_posted link
        end
      end
    end
  end
end
