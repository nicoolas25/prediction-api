module Entities
  class Player < Grape::Entity
    format_with(:timestamp) { |dt| dt.to_i }

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :nickname

    expose :social_associations, using: SocialAssociation, as: :social
  end
end
