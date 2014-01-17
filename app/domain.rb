module Domain
  module Common
    def initialize(attributes={})
      attributes.each{ |k, v| __send__("#{k}=", v) }
    end
  end

  autoload :Participation,            './app/domain/participation'
  autoload :Player,                   './app/domain/player'
  autoload :Prediction,               './app/domain/prediction'
  autoload :PredictionAnswer,         './app/domain/prediction_answer'
  autoload :PredictionAnswerChoice,   './app/domain/prediction_answer'
  autoload :PredictionAnswerClosest,  './app/domain/prediction_answer'
  autoload :PredictionAnswerExact,    './app/domain/prediction_answer'
  autoload :Question,                 './app/domain/question'
  autoload :QuestionComponent,        './app/domain/question_component'
  autoload :QuestionComponentChoice,  './app/domain/question_component'
  autoload :QuestionComponentClosest, './app/domain/question_component'
  autoload :QuestionComponentExact,   './app/domain/question_component'
  autoload :RankingService,           './app/domain/ranking_service'
end
