module Domain
  module Services
    class Winning
      def initialize(player, question_ids)
        @player = player
        @question_ids = question_ids
      end

      def winnings_for(question)
        prefetched_infos = question_hash[question.id]

        if prefetched_infos
          Earning.new(question).earning_for(prefetched_infos)
        else
          nil
        end
      end

      def predicted?(prediction)
        question = prediction.question
        prefetched_infos = question_hash[question.id]
        prefetched_infos[:cksum] == prediction.cksum
      end

    private

      def question_hash
        return @question_hash if @question_hash

        results = {}

        # Make one request to fetch the informations that allow the
        # winning computation
        participations = ::Domain::Participation.dataset.
          select(
            :participations__question_id,
            :participations__stakes,
            :participations__winnings,
            :predictions__amount,
            :predictions__players_count,
            :predictions__cksum).
          where(
            participations__question_id: @question_ids,
            participations__player_id: @player.id).
          join(
            :predictions,
            id: :prediction_id)

        # Puts the response in a Hash for faster access
        participations.each do |p|
          question_id = p.values[:question_id]
          results[question_id] = {
            players:  p.values[:players_count],
            amount:   p.values[:amount],
            stakes:   p.values[:stakes],
            winnings: p.values[:winnings],
            cksum:    p.values[:cksum]
          }
        end

        # Keep the hash for next calls
        @question_hash = results
      end
    end
  end
end
