module Domain
  module Badges
    class Prediction < Base
      STEPS = [5, 50, 100, 200, 500, 1000].freeze

      def applying?(player, question, prediction=nil)
        prediction != nil
      end

      def apply!
        @counter = @counter + 1
        @level = STEPS.select{ |i| @counter >= i }.size
      end
    end
  end
end
