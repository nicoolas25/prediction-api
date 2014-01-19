require 'httparty'

module SocialAPI
  class Facebook < Base
    include HTTParty

    base_uri 'https://graph.facebook.com'
    format :json

    def social_id
      return @social_id if @social_id

      response = self.class.get('/me', query: {access_token: @token, fields: 'id'})
      return nil unless response.code == 200
      @social_id = response.parsed_response['id']
    end
  end
end
