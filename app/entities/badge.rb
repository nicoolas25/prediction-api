module Entities
  class Badge < Grape::Entity
    expose :identifier
    expose :level
  end
end
