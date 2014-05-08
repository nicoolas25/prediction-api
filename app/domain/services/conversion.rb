module Domain
  class UnknownTargetError < Error ; end

  module Services
    class Conversion
      VALID_TARGETS = {
        'bonus_1' => [50,   4],
        'bonus_2' => [95,   8],
        'bonus_3' => [185, 16],
        'bonus_4' => [360, 32]
      }.freeze

      def initialize(player, target)
        @player = player
        @target = target
      end

      def apply!
        unless VALID_TARGETS.keys.include?(@target)
          raise UnknownTargetError.new(:unknown_target)
        end

        __send__(@target)
      end

      # Define bonus methods
      [1, 2, 3, 4].each do |count|
        define_method("bonus_#{count}") do
          DB.transaction do
            cost, amount = VALID_TARGETS["bonus_#{count}"]
            @player.decrement_cristals_by!(cost)
            amount.times do
              identifier = ::Domain::Bonuses.modules.keys.sample
              ::Domain::Bonus.create(player_id: @player.id, identifier: identifier)
            end
          end
        end
      end
    end
  end
end
