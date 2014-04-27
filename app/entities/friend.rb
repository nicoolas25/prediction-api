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
    expose :is_friend, if: ->(p, opts){ opts.has_key?(:is_friend) || opts.has_key?(:friend_service) } do |p, opts|
      if opts.has_key?(:is_friend)
        opts[:is_friend]
      else
        opts[:friend_service].friend_with?(p)
      end
    end
  end
end
