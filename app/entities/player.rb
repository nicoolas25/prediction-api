module Entities
  class Player < Grape::Entity
    include Common
    expose :id, if: :admin

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :statistics, if: ->(p, opts){ !opts[:admin] || opts[:details] } do |p, opts|
      {
        cristals: p.cristals,
        predictions: p.participations_dataset.count,
        questions: 0,
        friends: 0
      }
    end

    expose :nickname
    expose :first_name
    expose :last_name

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }

    expose :config, if: :config do |p, opts|
      defined?(APPLICATION_CONFIG) ? APPLICATION_CONFIG : nil
    end
  end
end
