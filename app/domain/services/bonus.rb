module Domain
  module Services
    class Bonus
      def initialize(player)
        @player = player
      end

      def remaining(identifier)
        bonus_hash[identifier][:remaining]
      end

      def used(identifier)
        bonus_hash[identifier][:used]
      end

    private

      def bonus_hash
        return @bonus_hash if @bonus_hash

        results = {}

        bonuses = @player.bonuses_dataset.
          select(
            :bonuses__identifier,
            Sequel.case([[{prediction_id: nil}, 0]], 1).as(:used),
            Sequel.function(:count, '*')).
          group(
            :identifier,
            Sequel.case([[{prediction_id: nil}, 0]], 1))


        # Puts the response in a Hash for faster access
        bonuses.each do |p|
          identifier = p.values[:identifier]
          target     = p.values[:used] == 0 ? :remaining : :used
          results[identifier] ||= {used: 0, remaining: 0}
          results[identifier][target] = p.values[:count]
        end

        # Keep the hash for next calls
        @bonus_hash = results
      end
    end
  end
end
