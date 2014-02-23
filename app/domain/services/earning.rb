module Domain
  module Services
    class Earning
      def initialize(question)
        @question = question
      end

      def distribute_earnings!
        # 3 requests triggered to determine the right prediction
        # - predictions
        # - answers
        # - components
        right_prediction = @question.predictions_dataset.eager(answers: :component).all.find(&:right?)

        prediction_amount = right_prediction.try(:amount) || 0
        question_amount = @question.amount
        wrong_amount = question_amount - prediction_amount

        DB.transaction do
          # Update wrong participation with 0 (1 SQL request)
          wrong_participations = @question.participations_dataset
          wrong_participations = wrong_participations.exclude(prediction_id: right_prediction.id) if right_prediction
          wrong_participations.update(winnings: 0)

          if right_prediction
            # Update the right participation (1 SQL request)
            winning_expr = Sequel.expr(:stakes) + (Sequel.expr(:stakes).cast(:float) / prediction_amount) * wrong_amount
            right_participations = @question.participations_dataset.where(prediction_id: right_prediction.id)
            right_participations.update(winnings: winning_expr)

            # Update the user cristals (1 SQL request)
            right_players = Player.dataset.
              from(:players, right_participations.select(:player_id, :winnings).as(:t1)).
              where(players__id: :t1__player_id)
            right_players.update(cristals: Sequel.expr(:cristals) + Sequel.expr(:winnings))
          end

          # Mark the question as answered
          @question.update(answered: true)
        end
      end

      def earning_for(participation)
        compute_groups!
        prediction_stakes = @stakes[participation.prediction]
        other_stakes = @total - prediction_stakes
        ratio = participation.stakes / prediction_stakes.to_f
        (other_stakes * ratio).to_i + participation.stakes
      end

      private

        # @stakes can be obtained by SQL
        # @total can be accumulated in the question
        def compute_groups!
          @total  ||= 0
          @groups ||= @question.participations_dataset.eager(:prediction).all.group_by(&:prediction)
          @stakes ||= @groups.each_with_object({}) do |(prediction, participations), hash|
            prediction_stakes = participations.reduce(0) do |sum, participation|
              participation.stakes + sum
            end
            hash[prediction] = prediction_stakes
            @total += prediction_stakes
          end
        end
    end
  end
end
