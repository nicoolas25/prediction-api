module Entities
  class Prediction < Grape::Entity
    expose :id

    expose :cksum

    expose :statistics do |p, opts|
      {
        cristals: p.amount,
        players: p.players_count,
        winnings: p.winnings_per_cristal
      }
    end

    expose :mine, if: :winning_service do |p, opts|
      opts[:winning_service].predicted?(p)
    end
  end
end

