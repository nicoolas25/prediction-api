module Entities
  class Friend < Grape::Entity
    include Common

    expose :nickname
    expose :first_name
    expose :last_name
    expose :created_at, format_with: :timestamp

    expose :statistics, if: :details do |p, opts|
      hash = {
        predictions: p.participations_dataset.count,
        questions: 0,
        friends: p.friends.count
      }

      hash[:cristals] = p.cristals if opts[:mine]

      hash
    end

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }
  end
end
