module Entities
  class SocialAssociation < Grape::Entity
    expose :provider do |sa, opts|
      SocialAPI::PROVIDERS[sa]
    end
  end
end
