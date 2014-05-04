require 'set'

module Domain
  module Services
    class Event
      def initialize(player, before_datetime, after_datetime)
        @player = player
        @before = before_datetime || Time.now
        @after  = after_datetime  || Time.now.at_midnight
      end

      def events
        return @events if @events

        results  = participations_creation.eager(:question, player: :social_associations).all.map{ |p| [p.created_at, p] }
        results += participations_solving.eager(:question, player: :social_associations).all.map{ |p| [p.question.solved_at, p]}
        results += friends_creation.eager(:social_associations).all.map{ |f| [f.created_at, f] }
        results += badges_creation.eager(player: :social_associations).all.map{ |b| [b.created_at, b] }
        @events  = results.sort_by!(&:first).map!(&:last).reverse!
      end

      def events_count
        participations_creation.count +
          participations_solving.count +
          friends_creation.count +
          badges_creation.count
      end

      def have_a_participation?(question)
        participations.member?(question.id)
      end

    private

      def friends_ids
        @friends_ids ||= @player.friends_dataset.select(:id)
      end

      def filter_dataset(attribute, dataset)
        dataset.
          where(Sequel.expr(attribute) >= @after).
          where(Sequel.expr(attribute) < @before)
      end

      def friends_creation
        filter_dataset(
          :players__created_at,
          @player.friends_dataset
        )
      end

      def participations_creation
        filter_dataset(
          :participations__created_at,
          ::Domain::Participation.dataset.
            where(
              Sequel.expr(player_id: @player.id) |
              Sequel.expr(player_id: friends_ids)
            )
        )
      end

      def participations_solving
        filter_dataset(
          :questions__solved_at,
          ::Domain::Participation.
            select_append(:questions__answered___solved).
            join(:questions, id: :question_id).
            where(questions__answered: true).
            where(Sequel.expr(:participations__winnings) > 0).
            where(
              Sequel.expr(player_id: @player.id) |
              Sequel.expr(player_id: friends_ids)
            )
        )
      end

      def badges_creation
        filter_dataset(
          :badges__created_at,
          ::Domain::Badge.dataset.
            visible.
            where(
              Sequel.expr(player_id: @player.id) |
              Sequel.expr(player_id: friends_ids)
            )
        )
      end

      def participations
        return @participations if @participations

        participations = Set.new
        question_ids = events.map do |e|
          if e.kind_of?(::Domain::Participation)
            e.question_id
          end
        end.compact!
        question_ids ||= []
        question_ids.uniq!
        @player.participations_dataset.
          where(question_id: question_ids).
          select(:question_id).
          all.
          each { |p| participations << p.question_id }

        @participations = participations
      end

      # LATER
      # def questions_creation
      # end
    end
  end
end
