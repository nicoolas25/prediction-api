module Domain
  class QuestionComponent
    include Common

    attr_accessor :answers, :valid_answer
  end

  class QuestionComponentChoice < QuestionComponent
    attr_accessor :choices

    def confirms?(answer)
      answer.value == valid_answer
    end
  end

  class QuestionComponentClosest < QuestionComponent
    def confirms?(answer)
      answers.all? do |a|
        answer == a || answer.diff <= a.diff
      end
    end
  end

  class QuestionComponentExact < QuestionComponent
    def confirms?(answer)
      answer.value == valid_answer
    end
  end
end
