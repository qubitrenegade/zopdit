# frozen_string_literal: true

module Zopdit
  module DB
    # Class to handle "Posts" db column
    class Posts
      include Zopdit::DB

      attr_accessor :table

      def initialize(table: :posts)
        self.table = table
        db.loggers << Logger.new($stdout)
      end

      def insert_post(title:, published: :published, direct_link:, post_link:, short_description:)
        db_insert(
          title: title,
          published: published,
          direct_link: direct_link,
          post_link: post_link,
          short_description: short_description
        )
      rescue Sequel::UniqueConstraintViolation => e
        puts "I'm sorry Dave, I can't do that... There's already a post with the title: \"#{title}\""
        puts "Error message: #{e}" if ZOPDIT_LOG_LEVEL
      end

      def latest_post
        ds.reverse_order(:published)&.first.then { |r| parse_dataset r }
      end

      def post_by_title(title)
        ds.where(title: title)&.first.then { |r| parse_dataset r }
      end

      # Not really sure if I like using `==` here like this
      alias inlucdes_latest_post? ==
      def ==(other)
        latest_post&.title == other.title &&
          latest_post.published == other.published
      end
    end
  end
end
