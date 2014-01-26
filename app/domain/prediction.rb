module Domain
  class Prediction
    unrestrict_primary_key

    many_to_one  :question
    one_to_many  :answers, class: '::Domain::PredictionAnswer'
    one_to_many  :participations
    many_to_many :players, join_table: :participations

    def right?
      answers.all?(&:right?)
    end
  end
end
