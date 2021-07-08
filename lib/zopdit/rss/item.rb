# frozen_string_literal: true

module Zopdit
  module RSS
    # Object Class for Weekly posts
    class Item
      attr_accessor :item

      def initialize(item)
        @item = item
      end

      def published
        item.pubDate
      end

      def title
        item.title
      end

      def description
        item.description
      end

      def short_description
        desc = description.match(%r{<p>(This week .*)<\/p>\n<p>The post.*<\/p>})&.captures&.first
        desc ||= description.match(%r{<p>(This week .*)</p>})&.captures&.first
        desc ||= description.match(%r{<p>(.*)<\/p>\n<p>The post.*<\/p>})&.captures&.first
        desc
      end

      def post_link
        item.guid.isPermaLink ? item.guid.content : item.link
      end

      def post_body
        @post_body ||= Faraday.get(post_link).body
      end

      # returns the direct link or nil
      def direct_link
        post_body.match(%r{https?://cache.escapistmagazine.com/.*\.mp4}).to_s
      end

      def print_item
        puts <<~EOITEM
          Post Date: #{pub_date}
          Tile: #{title}

          Direct Link: #{direct_link}
          Post Link: #{post_link}
          Description: #{short_description}

          ### Debug Content:
          Link: #{item.link}
          GUID: #{item.guid.content}
          Description: #{description}
          Category: #{item.category.content}
          Categories #{item.categories.map(&:content)}
        EOITEM
      end
    end
  end
end
