require 'grape-entity'

require './lib/grape_entity_patch'
require './app/domain'

module Entities
  module Common
    extend ActiveSupport::Concern

    included do
      format_with(:timestamp) { |dt| dt.to_i }
    end
  end

  autoload :Activity,          './app/entities/activity'
  autoload :Author,            './app/entities/author'
  autoload :Badge,             './app/entities/badge'
  autoload :Component,         './app/entities/component'
  autoload :Cristal,           './app/entities/cristal'
  autoload :Friend,            './app/entities/friend'
  autoload :Ladder,            './app/entities/ladder'
  autoload :Participation,     './app/entities/participation'
  autoload :Player,            './app/entities/player'
  autoload :Prediction,        './app/entities/prediction'
  autoload :Question,          './app/entities/question'
  autoload :SocialAssociation, './app/entities/social_association'
end
