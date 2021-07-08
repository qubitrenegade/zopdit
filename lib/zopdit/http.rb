# frozen_string_literal: true

module Zopdit
  # HTTP Mixing - Common HTTP methods
  module HTTP
    def connection(base_url, user_agent = ZOPDIT_USER_AGENT)
      con = Faraday::Connection.new base_url
      con.headers['User-Agent'] = user_agent
      con
    end

    def request(method, url, options: {}, klient: client)
      response = klient.send(method, url, options)
      raise "Error Code: #{response.status}" unless response.success?

      response.body.then { |s| parse_response s }
    end

    def request_time
      Time.now
    end
  end
end
