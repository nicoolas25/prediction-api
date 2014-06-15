module Domain
  class TagNotFound < Error ; end

  class Tag < ::Sequel::Model

    unrestrict_primary_key

    many_to_many :questions, join_table: :questions_tags

    def self.matching_ids(ids)
      tags = where(id: ids).all
      raise TagNotFound.new(:tag_not_found, 404) if tags.size != ids.size
      tags
    end
  end
end
