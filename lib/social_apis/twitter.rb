require 'securerandom'
require 'twitter'

module SocialAPI
  class Twitter < Base
    MAX_FRIENDS     = 2000
    CONSUMER_KEY    = 'uxn2mjhUoP9L6htVTOp1ng'
    CONSUMER_SECRET = 'XDs2otq17LBOV6U6XUow30NQFs7VXIkxnqdWjznCXa4'

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
      return [] unless social_id
      client.friend_ids(social_id.to_i).take(MAX_FRIENDS)
    end

    def share(locale, message, id)
      client.update(message) rescue false
    end

  private

    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        token_split = @token.split('~', 2)
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = token_split[0]
        config.access_token_secret = token_split[1]
      end
    end

    def infos
      return @infos unless @infos.nil?

      user = client.verify_credentials rescue nil

      if user
        name_split = user.name.split(' ', 2)
        @infos = {
          'id' => user.id,
          'first_name' => name_split[0],
          'last_name' => name_split[1]
        }
      else
        @infos = false
      end
    end
  end
end
