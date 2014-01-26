module Domain
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

      def open
        where{ expires_at > Time.now }
      end

      def with_locale(locale)
        exclude(:"label_#{locale}" => nil)
      end
    end
  end
end
