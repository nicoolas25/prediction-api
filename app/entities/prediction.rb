module Entities
  class Prediction < Grape::Entity
    expose :id
    expose :cksum
    expose :statistics do |p, opts|
      {
        cristals: p.amount,
        players: p.players_count
      }
    end
  end
end

