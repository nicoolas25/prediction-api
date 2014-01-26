require 'grape-entity'
require './app/domain'

module Entities
  autoload :Player,            './app/entities/player'
  autoload :Question,          './app/entities/question'
  autoload :SocialAssociation, './app/entities/social_association'
end
