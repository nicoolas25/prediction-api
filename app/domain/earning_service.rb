module Domain
  class EarningService
    def initialize(question)
      @question = question
    end

    def earning_for(participation)
      prediction_cristals = @cristals[participation.prediction]
      other_cristals = @total - prediction_cristals
      ratio = participation.cristals / prediction_cristals.to_f
      (other_cristals * ratio).to_i
    end

    private

      def compute_groups
        @total    ||= 0
        @groups   ||= @question.participations.group_by(&:prediction)
        @cristals ||= @groups.each_with_object({}) do |(prediction, participations), hash|
          prediction_cristals = participations.reduce(0) do |sum, participation|
            participation.cristals + sum
          end
          hash[prediction] = prediction_cristals
          @total += prediction_cristals
        end
      end
  end
end
