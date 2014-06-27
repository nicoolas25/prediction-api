module Domain
  class Match
    def self.all(player)
      questions = Question.dataset.visible.
        select(
          :id,
          :event_at,
          Sequel.lit(%Q{string_agg(cast(tag_id as varchar), ',') as tags}),
          Sequel.case([[{participations__question_id: nil}, 1]], 0).as(:remains)).
        join(:questions_tags, question_id: :id).
        join_table(:left, :participations, question_id: :questions__id, player_id: player.id).
        group(:id, :participations__question_id)

      DB.from(questions.as(:t1)).
        select(
          :event_at,
          :tags,
          Sequel.function(:count, '*').as(:total),
          Sequel.function(:sum, :remains).as(:remaining)).
        group(:event_at, :tags).
        where(Sequel.expr(:event_at) > Time.now).
        order(:event_at).
        all
    end
  end
end
