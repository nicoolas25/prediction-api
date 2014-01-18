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
      confirmed_answers.include?(answer)
    end

    protected

      def confirmed_answers
        sorted_answers = answers.sort_by(&:diff)
        answer = sorted_answers.first
        diff_min = answer && answer.diff
        sorted_answers.take_while{ |answer| answer.diff <= diff_min }
      end
  end

  class QuestionComponentExact < QuestionComponent
    def confirms?(answer)
      answer.value == valid_answer
    end
  end
end
