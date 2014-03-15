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

      def update_social_association_token(token)
        @assoc.update(token: token) if token.present? && @assoc.present?
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
        unless compute_target(kind, target_id)
          self.error = :unknown_share
          return false
        end

        unless can_share?
          self.error = :already_shared
          return false
        end

        msg = compute_message(locale)
        id = "#{@player.id}-#{kind}-#{target_id}"
        if @assoc.share(locale, msg, id)
          mark_as_shared!
          true
        else
          self.error = :not_shared
          false
        end
      end

      private

      def compute_target(kind, id)
        @target =
          case kind
          when 'participation'
            ::Domain::Participation.first(
              question_id: id,
              player_id: @player.id)
          when 'application'
            @player
          when 'badge'
            identifier, level = id.split('-')
            ::Domain::Badge.first(
              player_id: @player.id,
              identifier: identifier,
              level: level)
          else
            nil
          end
      end

      def can_share?
        @target && @target.shared_at.nil?
      end

      def mark_as_shared!
        @target && @target.update(shared_at: Time.now)
      end

      def compute_message(locale)
        case @target
        when ::Domain::Participation
          text = @target.question.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de répondre à la question : « #{text} » via Prédiction."
          else                "I just answered this question: '#{text}' through Prediction."
          end
        when ::Domain::Badge
          text = @target.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de gagner le badge : « #{text} » via Prédiction."
          else                "I just unlocked this badge: '#{text}' via Prédiction."
          end
        when ::Domain::Player
          case locale
          when :fr, 'fr' then "Rejoins moi sur l'application Prédiction et prédis l'avenir de la Coupe du monde 2014."
          else                "Come and join me on the Prediction application and predict the futur of the World Cup 2014."
          end
        end
      end
    end
  end
end
