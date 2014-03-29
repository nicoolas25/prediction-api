require './config/sidekiq'
require './app/domain'

module Workers
  autoload :QuestionAnswerer, './app/workers/question_answerer'
end
