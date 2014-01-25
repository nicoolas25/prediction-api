module Domain
  class Question
    LOCALES = %w(fr en).freeze

    include Common

    attr_accessor :id, :author, :labels, :tags, :components, :participations
  end
end
