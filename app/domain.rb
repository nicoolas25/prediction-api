require 'active_support'
require 'active_support/deprecation'
require 'active_support/core_ext'

require './config/log'
require './db/connect'
require './lib/social_apis'

module Domain
  class Error < StandardError ; end

  autoload :Badges,                   './app/domain/badges'
  autoload :EarningService,           './app/domain/earning_service'
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
  autoload :SocialAssociation,        './app/domain/social_association'

  autoload :I18nLabels,               './app/domain/concerns/i18n_labels'
  autoload :I18nChoices,              './app/domain/concerns/i18n_choices'
end
