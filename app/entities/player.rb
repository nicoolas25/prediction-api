module Entities
  class Player < Grape::Entity
    include Common
    expose :id

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :cristals, if: :admin

    expose :statistics, if: ->(p, opts){ !opts[:admin] || opts[:details] }

    expose :nickname
    expose :first_name
    expose :last_name

    expose :last_authentication_at, format_with: :timestamp
    expose :shared_at, format_with: :timestamp

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }

    expose :config, if: :config do |p, opts|
      defined?(APPLICATION_CONFIG) ? APPLICATION_CONFIG : nil
    end
  end
end
