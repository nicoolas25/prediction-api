require 'httparty'

module SocialAPI
  class GooglePlus < Base
    include HTTParty

    logger LOGGER, :info

    base_uri 'https://www.googleapis.com'
    format :json

    def first_name
      infos && infos['name']['givenName'] rescue nil
    end

    def last_name
      infos && infos['name']['familyName'] rescue nil
    end

    def social_id
      @social_id ||= infos && infos['id']
    end

    def avatar_url
      infos && infos['image'].try{ |hash| hash['url'] }
    end

    def email
      infos && infos['emails'].first['value'] rescue nil
    end

    def friend_ids
      ids = []
      url = '/plus/v1/people/me/people/visible'
      headers = {'Authorization' => "Bearer #{@token}"}
      fields = 'items/id,nextPageToken'

      response = self.class.get(url, headers: headers, query: {fields: fields})
      code = response.code

      while code == 200
        hash = response.parsed_response
        page_token = hash['nextPageToken']
        page = hash['items'].try{ |friends| friends.map{ |friend| friend['id'] } }

        break if page.nil? && page.empty?

        ids += page

        break unless page_token

        response = self.class.get(url, headers: headers, query: {fields: fields, pageToken: page_token})
        code = response.code
      end

      ids
    end

    def share(locale, message, id)
      # Consider the sharing via google plus successfull when the association is valid
      valid?
    end

    def extra_informations
      e_infos = {
        first_name:        infos['name']['givenName'],
        last_name:         infos['name']['familyName'],
        emails:           (infos['emails'] || []).map{ |obj| obj['value'] }.join(', '),
        birthday:          infos['birthday'],
        age_min:           infos['ageRange'] && infos['ageRange']['min'],
        age_max:           infos['ageRange'] && infos['ageRange']['max'],
        location:          infos['currentLocation'],
        gender:            infos['gender'],
        locale:            infos['language'],
        relationship:      infos['relationshipStatus']
      } if infos
      e_infos || super
    end

  private

    def infos
      return @infos unless @infos.nil?

      response = self.class.get(
        '/plus/v1/people/me',
        headers: {'Authorization' => "Bearer #{@token}"},
        query: {
          fields: "id,name(familyName,givenName),image(url),emails,birthday,ageRange,currentLocation,gender,language,relationshipStatus"
        }
      )

      if response.code == 200
        @infos = response.parsed_response
      else
        @infos = false
      end
    end
  end
end
