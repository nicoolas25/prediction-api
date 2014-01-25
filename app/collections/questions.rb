module Collections
  module Questions
    def self.create(question)
      err = validate(player, api)
      return [nil, err] if err.any?
      insert(question)
      [question, nil]
    end

    def self.insert(question)
      raise 'This question is already saved' if question.id

      # Insert the question
      attrs = {}
      attrs[:author_id] = question.player.id
      question.labels.each { |locale, label| attrs[:"label_#{locale}"] = label }
      question.id = DB[:questions].insert(attrs)

      # Insert the component
      question.components.each_with_index do |component, i|
        attrs = {}
        attrs[:position] = i
        attrs[:question_id] = question.id
        attrs[:kind] = Domain::QuestionComponent::KINDS.index(component.kind)
        component.labels.each { |locale, label| attrs[:"label_#{locale}"] = label }
        component.choices.each { |locale, choices| attrs[:"choices_#{locale}"] = choices.join(',') } if component.kind == :choices
        DB[:components].insert(attrs)
      end
    end

    def self.validate(question)
      err = {}

      # Question validations
      labels = question.labels
      if labels.nil? || labels.empty? || labels.values.any?{ |val| val.blank? }
        err['labels'] = 'not found'
      elsif labels.keys.any?{ |loc| !Domain::Question::LOCALES.include?(loc) }
        err['labels'] = 'unknown locale'
      end

      err['author'] = 'not found' if question.author.nil?

      # Components validations
      locales = question.labels.keys
      question.components.each_with_index do |component, i|
        validate_component(err, component, i, locales)
      end
    end

    def self.validate_component(err, component, i, locales)
      component_locales = component.labels.keys

      err["component_#{i}__kind"] = 'unknown' unless Domain::QuestionComponent::KINDS.include?(component.kind)

      # Labels
      if locales.any?{ |loc| !component_locales.include?(loc) }
        err["component_#{i}__labels"] = 'locale is missing'
      end

      # Choices
      if component.kind == :choices
        choices_locales = component.choices.keys
        if locales.any?{ |loc| !choices_locales.include?(loc) }
          err["component_#{i}__choices"] = 'locale is missing'
        end

        if choices.nil? || choices.empty? || choices.any?(&:blank?)
          err["component_#{i}__choices"] = 'empty'
        elsif choices.uniq.size != choices.size
          err["component_#{i}__choices"] = 'same'
        end
      end
    end
  end
end
