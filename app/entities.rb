require 'grape-entity'

require './app/domain'

module Entities
  module Common
    extend ActiveSupport::Concern

    included do
      format_with(:timestamp) { |dt| dt && dt.to_i }
    end
  end

  autoload :Activity,          './app/entities/activity'
  autoload :Author,            './app/entities/author'
  autoload :Badge,             './app/entities/badge'
  autoload :Bonus,             './app/entities/bonus'
  autoload :Component,         './app/entities/component'
  autoload :ConversionResult,  './app/entities/conversion_result'
  autoload :Cristal,           './app/entities/cristal'
  autoload :Friend,            './app/entities/friend'
  autoload :Ladder,            './app/entities/ladder'
  autoload :Match,             './app/entities/match'
  autoload :Participation,     './app/entities/participation'
  autoload :Player,            './app/entities/player'
  autoload :Prediction,        './app/entities/prediction'
  autoload :Question,          './app/entities/question'
  autoload :SocialAssociation, './app/entities/social_association'
  autoload :Tag,               './app/entities/tag'
end
