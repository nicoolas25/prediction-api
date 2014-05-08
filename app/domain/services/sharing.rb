# encoding: utf-8

module Domain
  module Services
    class Sharing
      attr_accessor :error

      def initialize(player)
        @player = player
      end

      def share(kind, locale, target_id)
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

        @player.social_associations.each_with_object({}) do |assoc, hash|
          provider_name = SocialAPI.provider(assoc.provider)
          if assoc.share(locale, msg, id)
            mark_as_shared!
            hash[provider_name] = :shared
          else
            hash[provider_name] = :not_shared
          end
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
          end
      end

      def can_share?
        @target && @target.shared_at.nil?
      end

      def mark_as_shared!
        if @target
          @target.update(shared_at: Time.now)
          @player.update(cristals: Sequel.expr(:cristals) + earnings)
        end
      end

      def earnings
        case @target
        when ::Domain::Participation then 2
        when ::Domain::Badge         then 2
        when ::Domain::Player        then 10
        end
      end

      def compute_message(locale)
        case @target
        when ::Domain::Participation
          text = @target.question.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de répondre à la question : « #{text} » via Pulpo."
          else                "I just answered this question: '#{text}' through Pulpo."
          end
        when ::Domain::Badge
          text = @target.labels[locale]
          case locale
          when :fr, 'fr' then "Je viens de gagner le badge : « #{text} » via Pulpo."
          else                "I just unlocked this badge: '#{text}' via Pulpo."
          end
        when ::Domain::Player
          case locale
          when :fr, 'fr' then "Rejoins moi sur l'application Pulpo et prédis l'avenir de la Coupe du monde 2014."
          else                "Come and join me on the Pulpo application and predict the futur of the World Cup 2014."
          end
        end
      end
    end
  end
end
