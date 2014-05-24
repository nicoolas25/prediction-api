require 'active_support'
require 'active_support/deprecation'
require 'active_support/core_ext'

require './config/log'
require './db/connect'
require './lib/social_apis'
require './lib/payment_apis'

# Set some inflections for bonuses
ActiveSupport::Inflector.inflections do |inflect| inflect.irregular('bonus', 'bonuses') end
Sequel.inflections                   do |inflect| inflect.irregular('bonus', 'bonuses') end

module Domain
  class Error < StandardError ; end

  autoload :Badge,                    './app/domain/badge'
  autoload :Badges,                   './app/domain/badges'
  autoload :Bonus,                    './app/domain/bonus'
  autoload :Bonuses,                  './app/domain/bonuses'
  autoload :ExtraInformation,         './app/domain/extra_information'
  autoload :Participation,            './app/domain/participation'
  autoload :Payment,                  './app/domain/payment'
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
  autoload :Services,                 './app/domain/services'
  autoload :SocialAssociation,        './app/domain/social_association'
  autoload :Tag,                      './app/domain/tag'

  autoload :I18nLabels,               './app/domain/concerns/i18n_labels'
  autoload :I18nChoices,              './app/domain/concerns/i18n_choices'
end
