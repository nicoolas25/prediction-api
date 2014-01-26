module Entities
  class Component < Grape::Entity
    expose :id

    expose :kind do |c, opts|
      Domain::QuestionComponent::KINDS[c.kind]
    end

    expose :label do |c, opts|
      c.labels[opts[:locale]]
    end

    expose :dev_info, exclude_nil: true do |c, opts|
      c.labels['dev']
    end

    expose :choices, if: ->(c, opts){ c.kind == 0 } do |c, opts|
      localized_choices = c.choices[opts[:locale]]
      dev_infos         = c.choices['dev']
      choices           = []
      localized_choices.each_with_index do |label, position|
        choice = {label: label, position: position}
        choice[:dev_info] = dev_infos[position] if dev_infos && dev_infos.kind_of?(Array)
        choices << choice
      end
      choices
    end
  end
end

