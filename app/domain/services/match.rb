module Domain
  module Services
    class Match
      def tags(tag_ids)
        @tags_hash ||= Domain::Tag.all.each_with_object({}){ |tag, h| h[tag.id] = tag }
        tag_ids.map { |id| @tags_hash[id.to_i] }
      end
    end
  end
end
