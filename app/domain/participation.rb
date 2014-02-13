module Domain
  class CristalsNeeded < Error ; end

  class Participation < ::Sequel::Model
    many_to_one :player
    many_to_one :prediction
    many_to_one :question

    def before_create
      super
      player.update(cristals: Sequel.expr(:cristals) - stakes)
    end

    def after_create
      super
      prediction.update_with_participation!(self)
      question.update_with_participation!(self)
    end

    def validate
      super
      if player.cristals < stakes
        errors.add(:player, 'need cristals')
        raise CristalsNeeded.new(:cristals_needed)
      end
    end
  end
end
