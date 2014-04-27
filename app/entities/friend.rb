module Entities
  class Friend < Grape::Entity
    include Common

    expose :id
    expose :nickname
    expose :first_name
    expose :last_name
    expose :created_at, format_with: :timestamp
    expose :shared_at, format_with: :timestamp
    expose :last_authentication_at, format_with: :timestamp
    expose :statistics, if: ->(p, opts){ opts[:details] }
    expose :social_associations, using: SocialAssociation, as: :social
  end
end
