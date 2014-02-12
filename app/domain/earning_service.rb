module Domain
  class EarningService
    def initialize(question)
      @question = question
    end

    def distribute_earnings!
      right_prediction = @question.predictions.find(&:right?)
      prediction_amount = right_prediction.try(:amount) || 0
      question_amount = @question.amount
      wrong_amount = question_amount - prediction_amount

      DB.transaction do
        # Update wrong participation with 0
        wrong_participations = @question.participations_dataset
        wrong_participations = wrong_participations.exclude(prediction_id: right_prediction.id) if right_prediction
        wrong_participations.update(winnings: 0)

        # Update the right participation
        if right_prediction
          @question.participations_dataset.
            where(prediction_id: right_prediction.id).
            update(winnings: Sequel.expr(:stakes) + (Sequel.expr(:stakes).cast(:float) / prediction_amount) * wrong_amount)
        end

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
