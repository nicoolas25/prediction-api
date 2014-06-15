module Domain
  class Match
    def self.all
      DB.from(
        Question.dataset.
          select(:id, :event_at, Sequel.lit(%Q{string_agg(cast(tag_id as varchar), ',' order by tag_id) as tags})).
          join(:questions_tags, question_id: :id).
          group(:id).
          as(:t1)).
      select(:event_at, :tags).
      group(:event_at, :tags).
      where(Sequel.expr(:event_at) > Time.now).
      order(:event_at).
      all
    end
  end
end
