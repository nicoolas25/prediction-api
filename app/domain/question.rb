module Domain
  class QuestionNotFound < Error ; end

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

      def answered_by(player)
        where(id: player.participations_dataset.select(:question_id))
      end

      def with_locale(locale)
        exclude(:"label_#{locale}" => nil)
      end
    end

    def update_with_participation!(participation)
      Question.dataset.where(id: self.id).update({
        amount: Sequel.expr(:amount) + participation.stakes,
        players_count: Sequel.expr(:players_count) + 1
      })
    end

    class << self
      def find_for_participation(player, id)
        question = dataset.open_for(player).where(id: id).eager(:components).first

        unless question
          if player.participations_dataset.where(question_id: id).empty?
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
