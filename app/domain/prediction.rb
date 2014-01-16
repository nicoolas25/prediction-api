class Prediction
  include Virtus.model

  attribute :author, Player

  attribute :participation, Participation

  attribute :answers, Array[PredictionAnswer]
end
