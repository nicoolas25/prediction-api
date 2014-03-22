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

    expose :statistics, if: ->(p, opts){ opts[:details] } do |p, opts|
      {
        # TODO
        best_ranking: 0,
        # TODO
        current_ranking: 0,
        # TODO
        used_bonus: 0,
        # TODO
        bonus: 0,
        # TODO
        questions: 0,
        badges: p.badges_dataset.visible.count,
        predictions: p.participations_dataset.count,
        friends: p.friends.count,
        cristals: p.cristals
      }
    end

    expose :social_associations, using: SocialAssociation, as: :social
  end
end
