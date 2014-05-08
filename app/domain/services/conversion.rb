module Domain
  class UnknownTargetError < Error ; end

  module Services
    class Conversion
      VALID_TARGETS = {
        'bonus_1' => 30,
        'bonus_2' => 50,
        'bonus_3' => 70,
        'bonus_4' => 90
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
            @player.decrement_cristals_by!(VALID_TARGETS["bonus_#{count}"])
            ::Domain::Bonuses.modules.keys.each do |identifier|
              count.times do
                ::Domain::Bonus.create(player_id: @player.id, identifier: identifier)
              end
            end
          end
        end
      end
    end
  end
end
