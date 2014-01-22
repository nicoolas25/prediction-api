module Domain
  class Question
    include Common

    attr_accessor :tags, :components, :participations
  end
end
