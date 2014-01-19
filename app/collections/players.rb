require './lib/social_apis'

module Collections
  module Players
    def self.create(provider, token, nickname)
      api = SocialAPI.for(provider, token)

      return [nil, ['oauth2Provider is invalid']] unless api
      return [nil, ['oauth2Token is invalid']] unless api.valid?

      social = Domain::SocialAssociation.new(provider: provider, id: api.social_id, token: token)
      social.player = player = Domain::Player.new(nickname: nickname, social_associations: [social])

      DB.transaction(isolation: :repeatable, retry_on: [Sequel::SerializationFailure]) do
        errors = validate(player, api)
        return [nil, errors] if errors.any?
        insert(api, player, social)
      end

      authenticate!(player)
      [player, nil]
    rescue
      LOGGER.error "User creation (#{nickname}) failed with the #{$!.class} - #{$!.message}"
      $!.backtrace[0..10].each{ |line| LOGGER.error line }

      [nil, ["exception raised: #{$!.message}"]]
    end

    private

    def self.validate(player, api)
      errors = []

      same_nickname = DB[:players].where(nickname: player.nickname).count > 0
      social_assocs = DB[:social_associations].where(provider: api.provider_id, id: api.social_id).count > 0

      errors << 'nickname is already taken' if same_nickname
      errors << 'oauth2Token is already taken' if social_assocs

      errors
    end

    def self.insert(api, player, social)
      player.id = DB[:players].insert(nickname: player.nickname)
      DB[:social_associations].insert(provider: api.provider_id, player_id: player.id, id: social.id, token: social.token)
    end

    def self.authenticate!(player)
      DB.transaction(retry_on: [Sequel::ConstraintViolation], num_retries: 30) do
        player.regenerate_token!
        DB[:players].where(id: player.id).update(token: player.token, token_expiration: player.token_expiration)
      end
    end
  end
end
