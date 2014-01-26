module Entities
  class Component < Grape::Entity
    expose :kind do |c, opts|
      Domain::QuestionComponent::KINDS[c.kind]
    end

    expose :label do |c, opts|
      c.labels[opts[:locale]]
    end

    expose :dev_info do |c, opts|
      c.labels['dev']
    end

    expose :choices, if: ->(c, opts){ c.kind == 0 } do |c, opts|
      { propositions: c.choices[opts[:locale]],
        dev_infos: c.choices['dev'] }
    end
  end
end

