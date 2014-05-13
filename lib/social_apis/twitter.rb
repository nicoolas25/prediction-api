require 'securerandom'
require 'twitter'

module SocialAPI
  class Twitter < Base
    MAX_FRIENDS     = 2000

    CONSUMER_KEY    = '5uCAjbygi4uUAUQSncykGLe72'
    CONSUMER_SECRET = 'jPGBFLdSnrGA9jZoB0muERPGte1oDKoDbCvrxGsZciHOLUSjr2'
    ACCOUNT_NAME    = '@PulpoGame'

    def first_name
      user && user.name.split(' ', 2)[0] rescue nil
    end

    def last_name
      user && user.name.split(' ', 2)[1] rescue nil
    end

    def social_id
      @social_id ||= user && user.id.to_s
    end

    def avatar_url
      user && user.profile_image_url? && user.profile_image_url.to_s
    end

    def email
      user && user.screen_name rescue nil
    end

    def friend_ids
      return [] unless social_id

      LOGGER.info "Fetching friends for #{social_id}."

      friends = client.friend_ids(social_id.to_i).take(MAX_FRIENDS)

      LOGGER.info "#{friends.size} friends found for #{social_id}."

      friends.map(&:to_s)
    end

    def share(locale, message, id)
      message = message.gsub('Pulpo', ACCOUNT_NAME)
      client.update(message) rescue false
    end

    def extra_informations
      infos = {
        screen_name:     user.screen_name,
        descriptions:    user.description,
        time_zone:       user.time_zone,
        location:        user.location,
        name:            user.name,
        friends_count:   user.friends_count,
        followers_count: user.followers_count,
        lang:            user.lang,
        created_at:      user.created_at.to_i
      } if user
      infos || super
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

    def user
      return @user unless @user.nil?

      LOGGER.info "Verifying credentials for #{@token[0..15]}."

      @user = client.verify_credentials rescue false

      LOGGER.info(
        @user ?
          "Credentials for #{@token[0..15]} are valid and matches #{user.id}." :
          "Credentials for #{token[0..15]} are invalid."
      )

      @user
    end
  end
end
