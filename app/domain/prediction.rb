module Domain
  class Prediction
    include Common

    attr_accessor :hash, :answers, :question

    def right?
      answers.all?(&:right?)
    end
  end
end
