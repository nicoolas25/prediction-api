class QuestionComponent
  include Virtus.model

  attribute :answers, PredictionAnswer

  attribute :valid_answer
end

class QuestionComponentChoice < QuestionComponent
  attribute :choices, Set[String]

  def confirms?(answer)
    answer.value == valid_answer
  end
end

class QuestionComponentExact < QuestionComponent
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

