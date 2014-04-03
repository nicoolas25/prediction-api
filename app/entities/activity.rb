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
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Participation) } do
      expose :question, using: Question
      expose :winnings, exclude_nil: true
      expose :prediction_exists do |a, opts|
        opts[:event_service].have_a_participation?(a.question)
      end
    end

    expose :player do |a, opts|
      author = a.respond_to?(:player) ? a.player : a
      Author.new(author)
    end
  end
end

