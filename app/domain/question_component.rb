module Domain
  class InvalidComponentError < Error ; end

  class QuestionComponent < ::Sequel::Model
    KINDS = %w(choices exact closest).freeze

    set_dataset :components

    unrestrict_primary_key

    many_to_one :question
    one_to_many :answers, class: '::Domain::PredictionAnswer'

    include I18nLabels
    include I18nChoices

    def validate
      super
      if new?
        errors.add(:kind, 'is unknown')     if kind.nil? || kind < 0 || kind >= KINDS.size
        errors.add(:labels, 'are missing')  if labels.empty?
        errors.add(:choices, 'are missing') if have_choices? && choices.empty?
      end
    end

    def confirms?(answer)
      case kind
      when 0, 1 then answer.value == valid_answer
      when 2    then confirmed_answers.include?(answer)
      end
    end

    def have_choices?
      kind == 0
    end

    class << self
      def build_many(components_params)
        results = components_params.map do |attrs|
          component         = Domain::QuestionComponent.new
          component.kind    = attrs[:kind].to_i
          component.labels  = attrs[:labels]
          component.choices = attrs[:choices] if component.have_choices?
          raise InvalidComponentError.new(:invalid_component) unless component.valid?
          component
        end
        results
      end
    end

  protected

    def confirmed_answers
      sorted_answers = answers.sort_by(&:diff)
      answer = sorted_answers.first
      diff_min = answer && answer.diff
      sorted_answers.take_while{ |answer| answer.diff <= diff_min }
    end
  end
end
