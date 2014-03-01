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
            winning_expr = Sequel.expr(:stakes) + Sequel.function(:floor, (Sequel.expr(:stakes).cast(:float) / prediction_amount) * wrong_amount)
            right_participations = @question.participations_dataset.where(prediction_id: right_prediction.id)
            right_participations.update(winnings: winning_expr)

            # Update the user cristals (1 SQL request)
            right_players = Player.dataset.
              from(:players, right_participations.select(:player_id, :winnings).as(:t1)).
              where(players__id: :t1__player_id)
            right_players.update(cristals: Sequel.expr(:cristals) + Sequel.expr(:winnings))
          end

          # Mark the question as answered / solved
          @question.update(answered: true, solved_at: Time.now)
        end
      end

      def earning_for(prefetched_infos, integer=true)
        prediction_amount = prefetched_infos[:amount]
        prediction_players = prefetched_infos[:players]
        participation_stakes = prefetched_infos[:stakes]
        participation_winnings = prefetched_infos[:winnings]

        if participation_winnings
          return participation_winnings
        end

        losses = @question.amount - prediction_amount
        ratio = participation_stakes.to_f / prediction_amount
        result = participation_stakes + (ratio * losses)
        integer ? result.to_i : result
      end
    end
  end
end
