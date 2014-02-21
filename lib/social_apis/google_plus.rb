require 'httparty'

module SocialAPI
  class GooglePlus < Base
    include HTTParty

    base_uri 'https://www.googleapis.com'
    format :json

    def first_name
      infos && infos['name']['givenName']
    end

    def last_name
      infos && infos['name']['familyName']
    end

    def social_id
      @social_id ||= infos && infos['id']
    end

  private

    def infos
      return @infos unless @infos.nil?

      response = self.class.get(
        '/plus/v1/people/me',
        headers: {'Authorization' => "Bearer #{@token}"},
        query: {fields: "id,name(familyName,givenName)"})

      if response.code == 200
        @infos = response.parsed_response
      else
        @infos = false
      end
    end
  end
end
