require 'grape-entity'

require './lib/grape_entity_patch'
require './app/domain'

module Entities
  autoload :Component,         './app/entities/component'
  autoload :Participation,     './app/entities/participation'
  autoload :Player,            './app/entities/player'
  autoload :Question,          './app/entities/question'
  autoload :SocialAssociation, './app/entities/social_association'
end
