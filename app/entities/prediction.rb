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

    expose :mine, exclude_nil: true, if: :winning_service do |p, opts|
      opts[:winning_service].predicted?(p) || nil
    end
  end
end

