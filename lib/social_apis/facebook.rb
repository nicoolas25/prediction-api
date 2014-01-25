require 'httparty'

module SocialAPI
  class Facebook < Base
    include HTTParty

    SMALL_PATTERN = "graph.facebook.com/%s/picture?height=100&width=100"
    BIG_PATTERN   = "graph.facebook.com/%s/picture?height=300&width=300"

    base_uri 'https://graph.facebook.com'
    format :json

    def first_name
      infos && infos['first_name']
    end

    def last_name
      infos && infos['last_name']
    end

    def social_id
      @social_id ||= infos && infos['id']
    end

    def avatar_url(big=false)
      social_id && ((big ? BIG_PATTERN : SMALL_PATTERN) % social_id)
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
