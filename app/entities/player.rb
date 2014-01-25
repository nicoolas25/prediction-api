module Entities
  class Player < Grape::Entity
    format_with(:timestamp) { |dt| dt.to_i }

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :nickname
    expose :first_name
    expose :last_name

    expose :avatars do |player, options|
      player.social_associations.first.try do |sa|
        provider = SocialAPI.for(sa.provider, nil, sa.id)
        {
          big:   provider.avatar_url(:big),
          small: provider.avatar_url(:small),
        }
      end
    end

    expose :social_associations, using: SocialAssociation, as: :social
  end
end
