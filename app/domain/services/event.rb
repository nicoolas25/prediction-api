module Domain
  module Services
    class Event
      def initialize(player, before_datetime, after_datetime)
        @player = player
        @before = before_datetime
        @after  = after_datetime
      end

      def answers
        participations_creation.eager(:question).all
      end

      def solutions
        participations_solving.eager(:question).all
      end

      def friends
        friends_creation.all
      end

    private

      def friends_ids
        @friends_ids ||= @player.friends_dataset.select(:id)
      end

      def filter_dataset(attribute, dataset)
        dataset = dataset.where(Sequel.expr(attribute) >= @after) if @after
        dataset = dataset.where(Sequel.expr(attribute) < @before) if @before
        dataset
      end

      def friends_creation
        filter_dataset(
          :players__created_at,
          @player.friends_dataset
        )
      end

      def participations_creation
        filter_dataset(
          :participation__created_at,
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
            join(:questions, id: :question_id).
            where(questions__answered: true).
            where(
              Sequel.expr(player_id: @player.id) |
              Sequel.expr(player_id: friends_ids)
            )
        )
      end

      # TODO
      # def badges_creation
      # end

      # LATER
      # def questions_creation
      # end
    end
  end
end
