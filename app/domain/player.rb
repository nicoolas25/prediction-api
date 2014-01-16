class Player
  include Virtus.model

  attribute :friends, Set[Player]
end
