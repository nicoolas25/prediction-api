module Domain
  module I18nChoices
    LOCALES = %w(fr en pt dev).freeze

    # Helper to access the choices
    def choices
      hash = {}.with_indifferent_access
      LOCALES.each_with_object(hash) do |locale, ls|
        if (val = self[:"choices_#{locale}"]).present?
          ls[locale] = val.split(',')
        end
      end
    end

    # Helper to define the choices
    def choices=(hash)
      hash = (hash || {}).with_indifferent_access
      LOCALES.each do |locale|
        if (val = hash[locale]).present?
          self.__send__(:"choices_#{locale}=", val.split(',').map(&:strip).join(','))
        end
      end
    end

    def choices_count
      choices.values.first.try(:size) || 0
    end
  end
end
