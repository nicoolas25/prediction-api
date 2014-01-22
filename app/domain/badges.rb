module Domain
  module Badges
    class Base
      attr_accessor :counter
      attr_accessor :level

      def applying?(player, question, prediction=nil)
        false
      end

      def apply!
        @counter = @counter + 1
        @level = @level + 1
      end

      def visible?
        @level > 0
      end
    end

    autoload :Prediction, './app/domain/badges/prediction'
  end
end
