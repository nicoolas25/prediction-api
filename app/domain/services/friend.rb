module Domain
  module Services
    class Friend
      def initialize(player)
        @player = player
      end

      def friend_with?(player)
        friends_hash.has_key?(player.id)
      end

    private

      def friends_hash
        return @friends_hash if @friends_hash

        results = {}

        @player.friends_dataset.select(:id).all.each do |player|
          results[player.id] = true
        end

        # Keep the hash for next calls
        @friends_hash = results
      end
    end
  end
end
