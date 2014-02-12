module Domain
  class QuestionNotFound < Error ; end
  class EmptyQuestion < Error ; end
  class InvalidQuestionError < Error ; end
  class MissingComponent < Error ; end
  class BadComponent < Error ; end

  class Question < ::Sequel::Model
    unrestrict_primary_key

    many_to_one  :author, class: '::Domain::Player'
    one_to_many  :components, class: '::Domain::QuestionComponent'
    one_to_many  :predictions
    one_to_many  :participations
    many_to_many :players, join_table: :participations

    include I18nLabels

    dataset_module do
      def global
        where(author_id: nil)
      end

      def open_for(player)
        ds = where{expires_at > Time.now}
        ds = ds.exclude(id: player.participations_dataset.select(:question_id)) unless player == :all
        ds
      end

      def expired
        exclude{expires_at > Time.now}
      end

      def answered_by(player)
        where(id: player.participations_dataset.select(:question_id))
      end

      def with_locale(locale)
        exclude(:"label_#{locale}" => nil)
      end
    end

    def validate
      super
      errors.add(:labels, 'are missing') if new? && labels.empty?
    end

    def update_with_participation!(participation)
      Question.dataset.where(id: self.id).update({
        amount: Sequel.expr(:amount) + participation.stakes,
        players_count: Sequel.expr(:players_count) + 1
      })
    end

    def create_with(components)
      raise EmptyQuestion.new(:empty_question) if components.nil? || components.empty?
      raise InvalidQuestion.new(:invalid_question) unless valid?

      DB.transaction do
        save
        components.each_with_index do |component, index|
          component.position = index
          add_component(component)
        end
      end
    end

    def answer_with(answers)
      # Check that all the components of the question are given
      unless components.all?{ |c| answers.has_key?(c.id.to_s) }
        raise MissingComponent.new(:missing_component)
      end

      # Check that all the answers are acceptable
      unless components.all?{ |c| c.accepts?(answers[c.id.to_s]) }
        raise BadComponent.new(:bad_answer)
      end

      update(answered: true)
    end

    class << self
      def find_for_answer(id)
        unless question = dataset.expired.where(id: id).eager(:components).first
          unless dataset.open_for(:all).where(id: id).empty?
            raise QuestionNotFound.new(:not_expired)
          end
        end
        question
      end

      def find_for_participation(player, id)
        unless question = dataset.open_for(player).where(id: id).eager(:components).first
          if player.participations_dataset.where(question_id: id).empty?
            raise QuestionNotFound.new(:question_not_found_or_expired)
          else
            raise QuestionNotFound.new(:participation_exists)
          end
        end
        question
      end

      def build(question_params)
        Domain::Question.new(question_params)
      end
    end

    # The following methods are maintainance

    def refresh_amount!
      update(amount: participations_dataset.select{sum(:stakes)}.first[:sum])
    end

    def refresh_players!
      update(players_count: participations_dataset.count)
    end
  end
end
