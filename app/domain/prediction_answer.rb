module Domain
  class PredictionAnswer
    include Common

    attr_accessor :target, :value

    def right?
      target.confirms?(self)
    end
  end

  class PredictionAnswerChoice < PredictionAnswer
  end

  class PredictionAnswerClosest < PredictionAnswer
    def diff
      @diff ||= (target.valid_answer - value).abs
    end
  end

  class PredictionAnswerExact < PredictionAnswer
  end
end
