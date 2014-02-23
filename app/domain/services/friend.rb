module Domain
  module Services
    class Friend
      def initialize(player, question_ids)
        @player = player
        @question_ids = question_ids
      end

      def friends_that_answered(question)
        question_hash[question.id]
      end

    private

      def question_hash
        return @question_hash if @question_hash

        results = Hash.new { 0 }

        # Make one request to fetch the number of friends that have answered
        # the @question_ids
        friend_ids = @player.friends_dataset.select(:id)
        participations = ::Domain::Participation.dataset.
          select(:question_id, Sequel.function(:count, Sequel.lit('*')).as(:friends_count)).
          where(player_id: friend_ids, question_id: @question_ids).
          group(:question_id)

        # Puts the response in a Hash
        participations.each do |p|
          qid = p.values[:question_id]
          count = p.values[:friends_count]
          results[qid] = count
        end

        # Keep the hash for next calls
        @question_hash = results
      end
    end
  end
end
