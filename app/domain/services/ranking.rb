module Domain
  module Services
    class Ranking
      def initialize(options={})
        @tag = options[:tag]
        @player = options[:friends_of]
      end

      def rank
        participations.each_with_object({}) do |p, scores|
          scores[p.player] = (scores[p.player] || 0) + p.winnings
        end
      end

      protected

        def participations
          if @tag && @player
            Collections::Participations.around_player_and_tagged_with(@player, @tag)
          elsif @tag
            Collections::Participations.tagged_with(@tag)
          elsif @player
            Collections::Participations.around_player(@player)
          else
            Collections::Participations.all
          end
        end
    end
  end
end
