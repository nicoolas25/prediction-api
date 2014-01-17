module Domain
  class Prediction
    include Common

    attr_accessor :author, :participation, :answers

    def initialize(attributes={})
      attributes.each{ |key, value| __send__("#{key}=", value) }
    end

    def right?
      answers.all?(&:right?)
    end
  end
end
