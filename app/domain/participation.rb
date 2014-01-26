module Domain
  class Participation < ::Sequel::Model
    many_to_one :player
    many_to_one :prediction
    many_to_one :question
  end
end
