module Entities
  class SocialAssociation < Grape::Entity
    expose :id

    expose :avatar_url

    expose :provider do |sa, opts|
      SocialAPI.provider(sa.provider)
    end

    expose :email, if: :admin
  end
end
