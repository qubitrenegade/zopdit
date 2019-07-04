# frozen_string_literal: true

require 'bundler/setup'
Bundler.require :default

require 'zopdit/version'

require 'zopdit/db'
require 'zopdit/db/posts'
require 'zopdit/http'
require 'zopdit/rss/feed'
require 'zopdit/rss/item'
require 'zopdit/reddit/client'

# Zopdit parent module
module Zopdit
  REDDIT_BASE_URL = 'https://www.reddit.com'
  REDDIT_AUTHED_URL = 'https://oauth.reddit.com'
  ZP_BASE_URL = 'https://www.escapistmagazine.com'
  ZP_FEED_PATH = '/v2/series/zero-punctuation/feed/'

  ZOPDIT_USER_AGENT = "Ruby:Zopdit:v#{Zopdit::VERSION} (by qubitrenegade)"

  # make this better
  ZOPDIT_LOG_LEVEL = ENV['ZOPDIT_LOG_LEVEL'] || false

  def self.root_dir
    Gem::Specification.find_by_name('zopdit').gem_dir
  end

  class Error < StandardError; end
  # Your code goes here...
end
