module Entities
  class Component < Grape::Entity
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
      r = { propositions: c.choices[opts[:locale]] }
      r[:dev_infos] = c.choices['dev'] if c.choices['dev']
      r
    end
  end
end

