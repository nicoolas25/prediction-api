module Domain
  class Prediction
    include Common

    attr_accessor :author, :participation, :answers

    def right?
      answers.all?(&:right?)
    end
  end
end
