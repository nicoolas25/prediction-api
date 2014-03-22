module Entities
  class Author < Grape::Entity
    expose :id
    expose :nickname
    expose :social_associations, using: SocialAssociation, as: :social
  end
end
