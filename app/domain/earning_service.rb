module Domain
  class EarningService
    def initialize(question)
      @question = question
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
        @groups ||= @question.participations.group_by(&:prediction)
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
