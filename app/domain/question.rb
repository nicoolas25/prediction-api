class Question
  include Virtus.model

  attribute :author, Player

  attribute :tags, Set[String]

  attribute :components, Array[QuestionComponent]

  attribute :participations, Set[Participation]

  def confirms?(prediction)
    components.each_with_index do |component, index|
      answer = prediction.answers[index]
      return false unless component.right?(answer)
    end

    true
  end
end
