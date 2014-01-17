module Domain
  class RankingService
    def initialize(tag=nil, friends_of=nil)
      @tag    = tag
      @player = friends_of
    end

    def rank!
      @scores = {}
      questions = tag ? Questions.tagged_with(tag) : Questions.all
      questions.each do |question|
        question.participations.each do |p|
          if @player.nil? || @player == p.player || @player.friends.include?(p.player)
            accumulate!(p.player, p.earnings)
          end
        end
      end
    end

    private

      def accumulate!(player, score)
        @scores[player] ||= 0
        @scores[player] += score
      end
  end
end
