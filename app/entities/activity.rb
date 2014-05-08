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
      if a.try(:answered)
        # Answered question
        a.solved_at
      elsif a.values[:last_participation_at].present?
        # Question participation
        a.values[:last_participation_at]
      else
        a.created_at
      end.to_i
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Badge) } do
      expose :identifier
      expose :level
    end

    with_options if: ->(a, opts){ a.kind_of?(::Domain::Question) } do
      expose :question do |a, opts|
        Question.new(a)
      end
      expose :prediction_exists do |a, opts|
        opts[:event_service].have_a_participation?(a)
      end
    end

    expose :players do |a, opts|
      case a
      when ::Domain::Badge
        [Author.new(a.player)]
      when ::Domain::Player
        [Author.new(a)]
      when ::Domain::Question
        (a.participants || []).map { |p| Author.new(p) }
      end
    end
  end
end

