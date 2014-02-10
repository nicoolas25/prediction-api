module Entities
  class Component < Grape::Entity
    expose :id

    expose :kind do |c, opts|
      Domain::QuestionComponent::KINDS[c.kind]
    end

    expose :label do |c, opts|
      opts[:locale] ? c.labels[opts[:locale]] : c.labels
    end

    expose :dev_info, exclude_nil: true do |c, opts|
      c.labels['dev']
    end

    expose :choices, if: ->(c, opts){ !opts[:locale] && c.kind == 0 } do |c, opts|
      choices = []
      c.choices.each do |locale, choices|
        choices.each_with_index do |label, position|
          choice = {locale: locale, label: label, position: position}
          choices << choice
        end
      end
      choices
    end

    expose :choices, if: ->(c, opts){ opts[:locale] && c.kind == 0 } do |c, opts|
      choices           = []
      localized_choices = c.choices[opts[:locale]]
      dev_infos         = c.choices['dev']
      localized_choices.each_with_index do |label, position|
        choice = {label: label, position: position}
        choice[:dev_info] = dev_infos[position] if dev_infos && dev_infos.kind_of?(Array)
        choices << choice
      end
      choices
    end
  end
end

