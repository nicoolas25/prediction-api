require './lib/social_apis'

module Collections
  module Players
    def self.create(provider, token, nickname)
      api = SocialAPI.for(provider, token)

      return [nil, [{field: 'oauth2Provider', reason: 'is invalid'}]] if api.nil?
      return [nil, [{field: 'oauth2Token',    reason: 'is invalid'}]] unless api.valid?

      errors = []

      social = Domain::SocialAssociation.new(provider: provider, id: api.social_id, token: token)
      social.player = player = Domain::Player.new(nickname: nickname, social_associations: [social])

      DB.transaction(isolation: :repeatable, retry_on: [Sequel::SerializationFailure]) do
        # Reset the errors just in case the transaction is retried
        errors = []

        same_nickname = DB[:players].where(nickname: nickname).count
        social_assocs = DB[:social_associations].where(provider: api.provider_id, id: social.id).count

        errors << {field: 'nickname',    reason: 'is already taken'} if same_nickname > 0
        errors << {field: 'oauth2Token', reason: 'is already taken'} if social_assocs > 0

        if errors.empty?
          player.id = DB[:players].insert(nickname: nickname)
          DB[:social_associations].insert(provider: api.provider_id, :player_id: player.id, id: social.id, token: token)
        end
      end

      # Returns errors
      return [nil, errors] if errors.any?

      # Authenticate the player
      DB.transaction(retry_on: [Sequel::ConstraintViolation], num_retries: 30) do
        player.regenerate_token!
        DB[:players].where(id: player_id).update(token: player.token, token_expiration: player.token_expiration)
      end

      [player, nil]
    rescue
      LOGGER.error "User creation (#{nickname}) failed with the #{$!.class} - #{$!.message}"
      [nil, errors << {field: 'unknown', reason: 'the database transaction failed'}]
    end
  end
end
