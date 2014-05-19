module Domain
  class QuestionNotFound < Error ; end
  class EmptyQuestion < Error ; end
  class InvalidQuestion < Error ; end
  class MissingComponent < Error ; end
  class BadComponent < Error ; end
  class AlreadyAnswered < Error ; end

  class Question < ::Sequel::Model
    unrestrict_primary_key

    many_to_one  :author, class: '::Domain::Player'
    one_to_many  :components, class: '::Domain::QuestionComponent'
    one_to_many  :predictions
    one_to_many  :participations
    many_to_many :players, join_table: :participations

    include I18nLabels

    attr_accessor :participants

    dataset_module do
      def visible
        where(Sequel.expr(:reveals_at) <= Time.now)
      end

      def global
        where(author_id: nil)
      end

      def for(player)
        exclude(id: player.participations_dataset.select(:question_id))
      end

      def of(player)
        where(id: player.participations_dataset.select(:question_id))
      end

      def answered_by_friends(player)
        friends_questions = player.friends_dataset.
          join(:participations, player_id: :players__id).
          select(:participations__question_id)
        where(id: friends_questions)
      end

      def expired
        exclude{expires_at > Time.now}
      end

      def open
        visible.where{expires_at > Time.now}
      end

      def answered_by(player)
        where(id: player.participations_dataset.select(:question_id))
      end

      def with_locale(locale)
        exclude(:"label_#{locale}" => nil)
      end

      def ordered(order=:asc)
        order(Sequel.__send__(order, :expires_at))
      end
    end

    def before_create
      super
      self.created_at   = Time.now
      self.reveals_at ||= self.created_at
    end

    def validate
      super
      errors.add(:labels, 'are missing') if labels.empty?
    end

    def update_with_participation!(participation)
      Question.dataset.where(id: self.id).update({
        amount: Sequel.expr(:amount) + participation.stakes,
        players_count: Sequel.expr(:players_count) + 1
      })
    end

    def update_components(new_components)
      raise EmptyQuestion.new(:empty_question) if new_components.nil? || new_components.empty?
      raise InvalidQuestion.new(:invalid_question) unless valid?

      to_delete = components.reject { |c1| new_components.any? { |c2| c1.id.to_s == c2['id'] }  }

      DB.transaction do
        save

        to_delete.each(&:destroy)

        new_components.each_with_index do |c1, index|
          c1.merge(position: index)
          if c2 = components.find { |c2| c1['id'] == c2.id.to_s }
            c2.update_attributes(c1)
            c2.save
          else
            add_component(QuestionComponent.build(c1))
          end
        end
      end
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

    def validate_answers!(answers)
      # Check that all the components of the question are given
      unless components.all?{ |component| answers.has_key?(component.id.to_s) }
        raise MissingComponent.new(:missing_component)
      end

      # Check that all the answers are acceptable
      unless components.all?{ |component| component.accepts?(answers[component.id.to_s]) }
        raise BadComponent.new(:bad_answer)
      end
    end

    # Expect that validate_answers! have already been called on the question
    def answer_with(answers)
      # Set all the component's answers
      components.each { |component| component.update(valid_answer: answers[component.id.to_s]) }

      # Update the earnings for the participations
      Services::Earning.new(self).distribute_earnings!

      # Defer the badge triggers
      Workers::BadgeTriggerer.perform_async(self.id)
    end

    # Run both Badges & Bonuses hooks (after participation ones)
    def run_pending_hooks!
      if answered && have_pending_hooks
        participations.each do |participation|
          hook = participation.win? ? :after_winning : :after_loosing
          Badges.run_hooks(hook, participation)
          Bonuses.run_hooks([:after_solving, hook], participation)
        end
        update(have_pending_hooks: false)
      end
    end

    class << self
      def find_for_answer(id)
        unless question = dataset.expired.where(id: id).eager(:components).first
          unless dataset.open.where(id: id).empty?
            raise QuestionNotFound.new(:not_expired)
          end
        end

        if question.try(:answered)
          raise AlreadyAnswered.new(:already_answered)
        end

        question
      end

      def find_for_update(id)
        unless question = dataset.open.where(id: id).eager(:components).first
          raise QuestionNotFound.new(:already_expired)
        end

        question
      end

      def find_for_participation(player, id)
        unless question = dataset.open.for(player).where(id: id).eager(:components).first
          if player.participations_dataset.for_question(id).empty?
            raise QuestionNotFound.new(:question_not_found_or_expired)
          else
            raise QuestionNotFound.new(:participation_exists)
          end
        end
        question
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
