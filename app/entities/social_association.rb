module Entities
  class SocialAssociation < Grape::Entity
    expose :provider do |sa, opts|
      SocialAPI.provider(sa.provider)
    end

    expose :id
  end
end
