require './app/domain/bonus'

module Domain
  class CristalsNeeded < Error ; end

  class Participation < ::Sequel::Model
    many_to_one :player
    many_to_one :prediction
    many_to_one :question
    one_to_one  :bonus, key: [:player_id, :prediction_id]

    attr_accessor :badges

    dataset_module do
      def for_question(question)
        id = question.respond_to?(:id) ? question.id : question
        where(question_id: id)
      end
    end

    def before_create
      super
      self.created_at = Time.now
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

    def win?
      winnings && winnings > 0
    end
  end
end
