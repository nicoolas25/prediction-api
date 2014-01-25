module Domain
  class Prediction
    include Common

    attr_accessor :answers, :question

    def right?
      answers.all?(&:right?)
    end
  end
end
