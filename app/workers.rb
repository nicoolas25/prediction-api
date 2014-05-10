require './config/sidekiq'
require './app/domain'

module Workers
  autoload :BadgeTriggerer,   './app/workers/badge_triggerer'
  autoload :FriendExplorer,   './app/workers/friend_explorer'
  autoload :QuestionAnswerer, './app/workers/question_answerer'
end
