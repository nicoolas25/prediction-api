module Domain
  class Question < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :author, class: '::Domain::Player'
    one_to_many :components, class: '::Domain::QuestionComponent'

    include I18nLabels
  end
end
