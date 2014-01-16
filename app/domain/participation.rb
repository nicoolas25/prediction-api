class Participation
  include Virtus.model

  attribute :player, Player

  attribute :prediction, Prediction

  attribute :earnings, Integer
end
