module Entities
  class Activity < Grape::Entity
    include Common

    expose :kind do |a, opts|
      if a.kind_of?(::Domain::Player)
        'friend'
      elsif a.kind_of?(::Domain::Badge)
        'badge'
      elsif a.values[:solved]
        'solution'
      else
        'answer'
      end
    end

    expose :created_at do |a, opts|
      if a.values[:solved]
        a.question.solved_at.to_i
      else
        a.created_at.to_i
      end
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Badge) } do
      expose :identifier
      expose :level
      expose :owner_id do |a, opts| a.player_id end
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Player) } do
      expose :id
      expose :nickname
      expose :social_associations, using: SocialAssociation, as: :social
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Participation) } do
      expose :player_id
      expose :question, using: Question
      expose :winnings, exclude_nil: true
    end
  end
end

