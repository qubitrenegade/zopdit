# frozen_string_literal: true

module Zopdit
  module Reddit
    # Reddit client class, connect to Reddit API
    class Client
      include Zopdit::HTTP

      attr_accessor :username, :password, :client_id, :secret,
                    :grant_type, :scope, :start_request, :subreddit,
                    :token_type, :token_expires

      def initialize(username:, password:, client_id:, secret:, **options)
        self.username = username
        self.password = password
        self.client_id = client_id
        self.secret = secret
        self.subreddit = options[:subreddit]
        self.grant_type = options[:grant_type] || 'password'
        self.scope = options[:scope] || '*'
        self.token_type = options[:token_type] || 'bearer'
      end

      def token_expired?
        Time.now > token_expires
      end

      def access_token
        # can refresh a token... why not just get a new one?
        if !@access_token || token_expired?
          @access_token = obtain_access_token
        else
          @access_token
        end
      end

      def access_token_options
        {
          username: username,
          password: password,
          grant_type: grant_type,
          scope: scope,
          token_type: token_type
        }
      end

      def obtain_access_token
        con = connection REDDIT_BASE_URL
        con.basic_auth client_id, secret
        start_request = request_time
        response = request(:post, '/api/v1/access_token', options: access_token_options, klient: con)
        self.token_expires =  start_request + response.expires_in
        response.access_token
      end

      def client
        @client ||= connect
      end

      def connect
        con = connection REDDIT_AUTHED_URL
        con.headers['Authorization'] = "BEARER #{access_token}"
        con
      end

      def parse_response(response)
        JSON.parse response, object_class: OpenStruct
      end

      def karma
        request 'get', '/api/v1/me/karma'
      end

      # if we move url and text up here we get errors.
      # maybe a more general "options building" function?
      def post_options(subreddit:, title:, kind: 'link')
        {
          ad: false,
          api_type: 'json',
          kind: kind,
          nsfw: false,
          sendreplies: true,
          sr: subreddit,
          title: title
        }
      end

      def post(title:, kind: 'link', subreddit: self.subreddit, url: nil, text: nil)
        warn 'URL and Text not both supported, posting URL' if url && text
        options = post_options kind: kind, subreddit: subreddit, title: title
        options[:url] = url if url
        options[:text] = text if !url && text

        request('post', '/api/submit', options: options).json
      end

      def comment(text, thing_id)
        options = {
          api_type: 'json',
          return_rtjson: true,
          text: text,
          thing_id: thing_id
        }
        request 'post', '/api/comment', options: options
      end
    end
  end
end
