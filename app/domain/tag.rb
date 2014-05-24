module Domain
  class Tag < ::Sequel::Model
    unrestrict_primary_key

    many_to_many :questions, join_table: :questions_tags
  end
end
