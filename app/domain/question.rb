module Domain
  class Question
    include Common

    attr_accessor :author, :tags, :components, :participations
  end
end
