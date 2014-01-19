require 'httparty'

module SocialAPI
  class Facebook < Base
    GRAPH_HOST = 'https://graph.facebook.com'

    def initialize(provider, token)
      super
    end

    def social_id
      return @social_id if @social_id
      response = HTTParty.get("#{GRAPH_HOST}/me", query: {access_token: @token})
      return nil unless response.code == 200
      @social_id = response.parsed_response['id']
    end
  end
end
