module Domain
  module Services
    class FriendQuestion
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

        results = {}

        # Make one request to fetch the friends that have answered
        # the @question_ids
        friend_ids = @player.friends_dataset.select(:id)
        participations = ::Domain::Participation.dataset.
          select(
            :participations__question_id,
            :participations__player_id,
            :participations__prediction_id,
            :social_associations__avatar_url,
            :social_associations__provider,
            :social_associations__id).
          where(
            participations__question_id: @question_ids,
            participations__player_id: friend_ids).
          join(
            :social_associations,
            player_id: :player_id).
          distinct(
            :participations__question_id,
            :participations__player_id,
            :social_associations__provider)

        # Puts the response in a Hash
        participations.each do |p|
          qid = p.values[:question_id]
          friend_hash = {
            id:            p.values[:player_id],
            prediction_id: p.values[:prediction_id],
            provider:      SocialAPI.provider(p.values[:provider]),
            avatar_url:    p.values[:avatar_url],
            social_id:     p.values[:id]
          }
          (results[qid] ||= []) << friend_hash
        end

        # Keep the hash for next calls
        @question_hash = results
      end
    end
  end
end
