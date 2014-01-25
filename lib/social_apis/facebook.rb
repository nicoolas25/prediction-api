require 'httparty'

module SocialAPI
  class Facebook < Base
    include HTTParty

    base_uri 'https://graph.facebook.com'
    format :json

    def first_name
      infos['first_name']
    end

    def last_name
      infos['last_name']
    end

    def social_id
      infos['id']
    end

  private

    def infos
      return @infos unless @infos.nil?

      response = self.class.get('/me', query: {access_token: @token, fields: 'id,first_name,last_name'})

      if response.code == 200
        @infos = response.parsed_response
      else
        @infos = false
      end
    end
  end
end
