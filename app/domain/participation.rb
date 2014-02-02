module Domain
  class Participation < ::Sequel::Model
    many_to_one :player
    many_to_one :prediction
    many_to_one :question

    def after_create
      super
      prediction.update_with_participation!(self)
      question.update_with_participation!(self)
    end
  end
end
