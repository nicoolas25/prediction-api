module Domain
  module Services
    class Event
      def initialize(player, before_datetime, after_datetime)
        @player = player
        @before = before_datetime
        @after  = after_datetime
      end

      def events
        results =  participations_creation.eager(:question).all.map{ |p| [p.created_at, p] }
        results += participations_solving.eager(:question).all.map{ |p| [p.question.solved_at, p]}
        results += friends_creation.eager(:social_associations).all.map{ |f| [f.created_at, f] }
        results.sort_by!(&:first).map!(&:last).reverse!
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

      # TODO
      # def badges_creation
      # end

      # LATER
      # def questions_creation
      # end
    end
  end
end
