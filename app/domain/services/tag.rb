module Domain
  module Services
    class Tag
      def question_count(tag)
        question_hash[tag.id] || 0
      end

    private

      def question_hash
        return @question_hash if @question_hash

        results = {}

        # Make one request to fetch the participation informations
        tags = ::Domain::Tag.dataset.
          select(:tags__id, Sequel.function(:count, '*').as(:count)).
          join(:questions_tags, tag_id: :id).
          group(:tags__id)

        # Puts the response in a Hash for faster access
        tags.each do |t|
          id    = t.values[:id]
          count = t.values[:count]
          results[id] = count
        end

        # Keep the hash for next calls
        @question_hash = results
      end
    end
  end
end
