class PredictionAnswerDoNotMatch < StandardError
  attr_reader :component, :answer

  def initialize(component, answer)
    @component = component
    @answer    = answer
  end
end
