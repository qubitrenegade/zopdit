# frozen_string_literal: true

module Zopdit
  module DB
    # Class to handle "Posts" db column
    class Posts
      include Zopdit::DB

      attr_accessor :table

      def initialize(table: :posts)
        self.table = table
        db.loggers << Logger.new($stdout) if ZOPDIT_LOG_LEVEL
      end

      def insert_post(post, options)
        # is this actually any clearer?
        opt = %i[title published direct_link post_link short_description].each_with_object({}) do |option, memo|
          memo[option] = post.send option
        end
        db_insert opt.merge(options)
      rescue Sequel::UniqueConstraintViolation => e
        puts "I'm sorry Dave, I can't do that... There's already a post with the title: \"#{post.title}\""
        puts "Error message: #{e}" if ZOPDIT_LOG_LEVEL
      end

      def latest_post
        ds.reverse_order(:published).first.then { |r| parse_dataset r }
      end

      def post_by_title(title)
        ds.where(title: title).first.then { |r| parse_dataset r }
      end

      def links_to_post
        ds.where(posted: false, to_post: true).all.map { |r| parse_dataset r }
      end

      def update_posted(post)
        ds.where(id: post.id).update(posted: true, to_post: false)
      end

      def un_update_posted(id)
        ds.where(id: id).update(posted: false, to_post: true)
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
