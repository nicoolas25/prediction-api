module Domain
  class QuestionComponent < ::Sequel::Model
    KINDS = %w(choices exact closest).freeze

    set_dataset :components

    many_to_one :question

    include I18nLabels
    include I18nChoices

    def confirms?(answer)
      case kind
      when 0, 1 then answer.value == valid_answer
      when 2    then confirmed_answers.include?(answer)
      end
    end

    def have_choices?
      kind == 0
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
