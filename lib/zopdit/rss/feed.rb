# frozen_string_literal: true

module Zopdit
  module RSS
    # Class to handle interacting with an RSS feed.
    class Feed
      include Zopdit::HTTP

      attr_accessor :base_url, :feed_path, :items, :title
      attr_writer :feed

      def initialize(base_url: ZP_BASE_URL, feed_path: ZP_FEED_PATH)
        self.base_url = base_url
        self.feed_path = feed_path
      end

      def client
        @client ||= connection base_url
      end

      def parse_response(response)
        ::RSS::Parser.parse response
      end

      def feed
        @feed ||= update_feed
      end

      def update_feed
        self.feed = read_feed
        self.title = feed.channel.title
        self.items = feed.items.map { |i| Item.new i }
        feed
      end

      def read_feed
        request :get, feed_path
      end
    end
  end
end
