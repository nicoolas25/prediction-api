require './config/log'
require './app/domain'

module Collections
  autoload :Participations,     './app/collections/participations'
  autoload :Players,            './app/collections/players'
  autoload :SocialAssociations, './app/collections/social_associations'
end
