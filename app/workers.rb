require './config/sidekiq'
require './app/domain'

module Workers
  autoload :QuestionAnswerer, './app/workers/question_answerer'
  autoload :BadgeTriggerer,   './app/workers/badge_triggerer'
end
