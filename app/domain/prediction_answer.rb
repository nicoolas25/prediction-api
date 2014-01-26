module Domain
  class PredictionAnswer
    many_to_one :prediction
    many_to_one :component, class: '::Domain::QuestionComponent'

    def right?
      component.confirms?(self)
    end

    def diff
      @diff ||= (component.valid_answer - value).abs
    end
  end
end
