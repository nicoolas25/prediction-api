module Entities
  class SocialAssociation < Grape::Entity
    expose :provider
    expose :id
  end
end
