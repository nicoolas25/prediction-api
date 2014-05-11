module Domain
  module I18nLabels
    LOCALES = %w(fr en pt dev).freeze

    # Helper to access the labels
    def labels
      hash = {}.with_indifferent_access
      LOCALES.each_with_object(hash) do |locale, ls|
        if (val = self[:"label_#{locale}"]).present?
          ls[locale] = val
        end
      end
    end

    # Helper to define the labels
    def labels=(hash)
      hash = (hash || {}).with_indifferent_access
      LOCALES.each do |locale|
        if (val = hash[locale]).present?
          self.__send__(:"label_#{locale}=", val)
        end
      end
    end
  end
end
