require 'httparty'

module SocialAPI
  class Facebook < Base
    include HTTParty

    logger LOGGER, :info

    MAX_FRIENDS = 2000

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

    def friend_ids
      response = self.class.get(
        '/me/friends',
        query: {access_token: @token, limit: MAX_FRIENDS, fields: 'id'})

      if response.code == 200
        hash = response.parsed_response
        ids = hash['data'].try{ |friends| friends.map{ |friend| friend['id'] } }
        ids || []
      else
        []
      end
    end

  private

    def infos
      return @infos unless @infos.nil?

      response = self.class.get(
        '/me',
        query: {access_token: @token, fields: 'id,first_name,last_name'})

      if response.code == 200
        @infos = response.parsed_response
      else
        @infos = false
      end
    end
  end
end
