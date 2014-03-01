module Entities
  class Friend < Grape::Entity
    include Common

    expose :nickname
    expose :first_name
    expose :last_name
    expose :created_at, format_with: :timestamp

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }
  end
end
