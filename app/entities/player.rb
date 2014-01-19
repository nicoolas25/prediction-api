module Entities
  class Player < Grape::Entity
    expose :id

    expose :token,            if: :token
    expose :token_expiration, if: :token

    expose :nickname

    expose :social_associations, using: SocialAssociation, as: :social
  end
end
