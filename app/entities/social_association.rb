module Entities
  class SocialAssociation < Grape::Entity
    expose :provider { |sa, opts| SocialAPI.provider(sa.provider) }
    expose :id
  end
end
