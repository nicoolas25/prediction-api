module Entities
  class Cristal < Grape::Entity
    include Common

    expose :cristals do |integer, opts|
      integer
    end
  end
end


