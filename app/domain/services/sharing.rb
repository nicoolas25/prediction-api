# encoding: utf-8

module Domain
  module Services
    class Sharing
      attr_accessor :error

      def initialize(player, provider_name)
        @player      = player
        @provider_id = SocialAPI::PROVIDERS.index(provider_name)
        @assoc       = @player.social_associations_dataset.first(provider: @provider_id)
      end

      def ready?
        self.error = false

        if @provider_id
          if @assoc
            unless @assoc.alive?
              self.error = :social_association_dead
            end
          else
            self.error = :social_association_missing
          end
        else
          self.error = :provider_not_found
        end

        not self.error
      end

      def share!(kind, locale, target_id)
        target = compute_target(kind, target_id)
        return false unless target

        id  = "#{@player.id}-#{kind}"
        id << "-#{@target.id}" unless target.kind_of?(String)
        msg = compute_message(locale, target)
        @assoc.share(locale, message, id)
      end

      private

      def compute_target(kind, id)
        case kind
        when 'participation' then ::Domain::Question.first(id: id)
        when 'application'   then kind
        when 'badge'         then ::Domain::Badge.first(id: id)
        else nil
        end
      end

      def compute_message(locale, target)
        case target
        when ::Domain::Question
          text = target.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de répondre à la question : « #{text} » via Prédiction."
          else :en, 'en' then "I just answered this question: '#{text}' through Prediction."
          end
        when ::Domain::Badge
          text = target.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de gagner le badge : « #{text} » via Prédiction."
          else :en, 'en' then "I just unlocked this badge: '#{text}' via Prédiction."
          end
        when 'application'
          case locale
          when :fr, 'fr' then "Rejoins moi sur l'application Prédiction et prédis l'avenir de la Coupe du monde 2014."
          else :en, 'en' then "Come and join me on the Prediction application and predict the futur of the World Cup 2014."
          end
        else
          raise "Unexpected target: #{target}"
        end
      end
    end
  end
end
