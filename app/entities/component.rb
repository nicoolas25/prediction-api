module Entities
  class Component < Grape::Entity
    expose :id

    expose :kind do |c, opts|
      Domain::QuestionComponent::KINDS[c.kind]
    end

    expose :labels, if: :admin
    expose :label, if: :locale do |c, opts|
      c.labels[opts[:locale]]
    end

    expose :dev_info do |c, opts|
      c.labels['dev']
    end

    expose :valid_answer

    expose :choices, if: ->(c, opts){ c.kind == 0 } do |c, opts|
      choices = []
      if opts[:locale]
        localized_choices = c.choices[opts[:locale]]
        dev_infos         = c.choices['dev']
        localized_choices.each_with_index do |label, position|
          choice = {label: label, position: position}
          choice[:dev_info] = dev_infos[position] if dev_infos && dev_infos.kind_of?(Array)
          choices << choice
        end
      elsif opts[:admin]
        c.choices.each do |locale, choice_list|
          choice_list.each_with_index do |label, position|
            choice = {locale: locale, label: label, position: position}
            choices << choice
          end
        end
      end
      choices
    end
  end
end

