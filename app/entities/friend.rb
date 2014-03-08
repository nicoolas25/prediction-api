module Entities
  class Friend < Grape::Entity
    include Common

    expose :nickname
    expose :first_name
    expose :last_name
    expose :created_at, format_with: :timestamp

    expose :statistics, if: :details do |p, opts|
      {
        best_ranking: 0,
        current_ranking: 0,
        used_bonus: 0,
        bonus: 0,
        badges: 0,
        questions: 0,
        predictions: p.participations_dataset.count,
        friends: p.friends.count,
        cristals: p.cristals
      }
    end

    expose :social_associations,
      using: SocialAssociation,
      as: :social,
      if: ->(p, opts){ !opts[:admin] || opts[:details] }
  end
end
