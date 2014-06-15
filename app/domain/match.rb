module Domain
  class Match
    def self.all
      DB.from(
        Question.dataset.
          select(:id, :event_at, Sequel.function(:string_agg, Sequel.cast_string(:questions_tags__tag_id), ',').as(:tags)).
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
