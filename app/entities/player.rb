module Entities
  class Player < Grape::Entity
    include Common

    expose :token,            if: :token
    expose :token_expiration, if: :token, format_with: :timestamp

    expose :statisics do |p, opts|
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

    expose :social_associations, using: SocialAssociation, as: :social

    expose :config, if: :config do |p, opts|
      defined?(APPLICATION_CONFIG) ? APPLICATION_CONFIG : nil
    end
  end
end
