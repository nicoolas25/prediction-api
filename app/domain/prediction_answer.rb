class PredictionAnswer
  include Virtus.model

  attribute :target, QuestionComponent
end

class PredictionAnswerChoice < PredictionAnswer
  attribute :value, String
end

class PredictionAnswerExact < PredictionAnswer
  attribute :value, Float
end

class PredictionAnswerClosest < PredictionAnswer
  attribute :value, Float

  def diff
    @diff ||= (target.answer - value).abs
  end
end
