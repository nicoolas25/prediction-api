module Domain
  module Services
    class SharingQuestion
      def initialize(player, question_ids)
        @player = player
        @question_ids = question_ids
      end

      def shared?(question)
        question_hash[question.id] != nil
      end

    private

      def question_hash
        return @question_hash if @question_hash

        results = {}

        # Make one request to fetch the participation informations
        participations = ::Domain::Participation.dataset.
          select(
            :participations__question_id,
            :participations__shared_at).
          where(
            participations__question_id: @question_ids,
            participations__player_id: @player.id)

        # Puts the response in a Hash for faster access
        participations.each do |p|
          question_id = p.values[:question_id]
          shared_at   = p.values[:shared_at]
          results[question_id] = shared_at
        end

        # Keep the hash for next calls
        @question_hash = results
      end
    end
  end
end
