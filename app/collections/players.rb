require './lib/social_apis'

module Collections
  module Players
    def self.create(provider, token, nickname)
      api, err = find_api(provider, token)

      return [nil, err] if err

      social = Domain::SocialAssociation.new(
        provider: provider,
        id: api.social_id,
        token: token)
      social.player = player = Domain::Player.new(
        nickname: nickname,
        first_name: api.first_name,
        last_name: api.last_name,
        social_associations: [social])

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

    def self.find_by_social(provider, token)
      api, err = find_api(provider, token)

      return [nil, err] if err

      attrs = DB[:players].
        select_all(:players).
        join(:social_associations, player_id: :id).
        where(social_associations__provider: api.provider_id, social_associations__id: api.social_id).
        first

      return [nil, ["oauth2Token can't lead to an existing user"]] unless attrs

      player = Domain::Player.new(attrs)
      Collections::SocialAssociations.fill(player)

      [player, nil]
    end

    def self.authenticate!(player)
      DB.transaction(retry_on: [Sequel::ConstraintViolation], num_retries: 30) do
        player.regenerate_token!
        DB[:players].where(id: player.id).update(token: player.token, token_expiration: player.token_expiration)
      end
    end

    private

    def self.find_api(provider, token)
      api = SocialAPI.for(provider, token)

      return [nil, ['oauth2Provider is invalid']] unless api
      return [nil, ['oauth2Token is invalid']]    unless api.valid?

      [api, nil]
    end

    def self.validate(player, api)
      errors = []

      same_nickname = DB[:players].where(nickname: player.nickname).count > 0
      social_assocs = DB[:social_associations].where(provider: api.provider_id, id: api.social_id).count > 0

      errors << 'nickname is already taken' if same_nickname
      errors << 'oauth2Token is already taken' if social_assocs

      errors
    end

    def self.insert(api, player, social)
      player.id = DB[:players].insert(
        nickname: player.nickname,
        first_name: player.first_name,
        last_name: player.last_name)

      DB[:social_associations].insert(
        provider: api.provider_id,
        player_id: player.id,
        id: social.id,
        token: social.token)
    end
  end
end
