require 'securerandom'

require './lib/social_apis'
require './app/domain/prediction'
require './app/domain/bonus'

module Domain
  class RegistrationError < Error ; end
  class SessionError < Error ; end
  class SocialAPIError < Error ; end
  class ParticipationError < Error ; end

  class Player < ::Sequel::Model
    DEFAULT_CRISTALS_COUNT = 30
    DURATION_BETWEEN_AUTO_EARN = 1.hour
    CRISTAL_BY_AUTO_EARN = 2

    unrestrict_primary_key

    one_to_many  :social_associations
    one_to_many  :participations
    one_to_many  :badges
    one_to_many  :bonuses
    many_to_many :predictions, join_table: :participations
    many_to_many :questions, join_table: :participations

    # A friendship is different depending on the social network
    # it's from. GooglePlus and Twitter are directed edges but
    # facebook have symetric relations.
    FRIENDSHIPS_EXPR = ->(id){
      (Sequel.expr(friendships__left_id: id) &
       Sequel.expr(friendships__right_id: :players__id)) |
      (Sequel.expr(friendships__right_id: id) &
       Sequel.expr(friendships__left_id: :players__id) &
       Sequel.expr(friendships__provider: SocialAPI::SYMETRIC_FRIENDSHIP_PROVIDERS))
    }

    many_to_many :friends, class: Player, dataset: ->{
      Player.exclude(players__id: id).join(:friendships, FRIENDSHIPS_EXPR[id])
    }

    # Friends including himself
    def circle_dataset
      Player.
        join_table(:left, :friendships, FRIENDSHIPS_EXPR[id]).
        where(Sequel.negate(right_id: nil) | Sequel.expr(players__id: id)).
        distinct
    end

    def validate
      super
      errors.add(:nickname, 'doesn\'t match')   if new? && !(nickname =~ /^[a-z0-9_]*$/i)
      errors.add(:nickname, 'is too short')     if new? && nickname.size < 4
      errors.add(:nickname, 'is already taken') if new? && Player.where(nickname: nickname).count > 0
    end

    def before_create
      super
      self.cristals     ||= DEFAULT_CRISTALS_COUNT
      self.created_at   ||= Time.now
      self.auto_earn_at ||= Time.now
    end

    def after_create
      super
      Services::Ranking.ensure_player_presence(self)
    end

    def regenerate_token!
      self.token = SecureRandom.hex
      self.token_expiration = Time.now + 2.days
    end

    def touch!
      self.last_authentication_at    = self.current_authentication_at
      self.current_authentication_at = Time.now
    end

    def expire_token!
      self.token_expiration = Time.now
    end

    def authenticate!(api)
      # Update the social association with the last know token and avatar
      SocialAssociation.dataset.
        where(player_id: self.id, provider: api.provider_id).
        update(token: api.token, avatar_url: api.avatar_url)

      # Update the application token
      DB.transaction(retry_on: [Sequel::ConstraintViolation], num_retries: 30) do
        regenerate_token!
        touch!
        save_changes
      end
    end

    def participate_to!(question, stakes, raw_answers, bonus=nil)
      # Verify that the stakes are in the expected range
      if defined?(APPLICATION_CONFIG)
        range = APPLICATION_CONFIG[:stakes]
        if range[:min] > stakes || range[:max] < stakes
          raise ParticipationError.new(:invalid_stakes)
        end
      end

      prediction = participation = nil

      DB.transaction do
        prediction = Prediction.first_or_create_from_raw_answers(raw_answers, question)
        participation = Participation.create(
          player: self,
          question: question,
          prediction: prediction,
          stakes: stakes)
        bonus.try(:use_for!, participation)
      end

      # Reload the participation's bonus when needed
      if bonus
        participation.bonus(true)
      end

      # Keep track of the generated badges relative to the participation
      generated_badges = Badges.run_hooks(:after_participation, participation)
      participation.badges = generated_badges.select(&:visible?)

      participation
    rescue Sequel::UniqueConstraintViolation
      # Never used in the test suite because it needs concurrency
      raise QuestionNotFound.new(:participation_exists)
    end

    def ask_for_cristals!
      DB.transaction(isolation: :repeatable) do
        if reload.auto_earn_at + DURATION_BETWEEN_AUTO_EARN < Time.now
          DB[:players].
            where(id: id).
            update({
              auto_earn_at: Time.now,
              cristals: Sequel.expr(:cristals) + CRISTAL_BY_AUTO_EARN
            })
        end
      end
      reload
    end

    def increment_cristals_by!(amount)
      self.cristals += amount
      DB[:players].where(id: id).update(cristals: Sequel.expr(:cristals) + amount)
    end

    def update_social_association(provider_name, token)
      api = self.class.social_api(provider_name, token)
      DB.transaction(isolation: :repeatable, retry_on: [Sequel::SerializationFailure]) do
        socass   = social_associations_dataset.where(provider: api.provider_id).first
        socass ||= SocialAssociation.new(provider: api.provider_id, player_id: id)
        socass.set(id: api.social_id, token: token)
        if socass.valid?
          if socass.new?
            socass.save
          else
            # Use this update method since the classic save will not work
            # without primary key.
            SocialAssociation.dataset.
              where(player_id: id, provider: api.provider_id).
              update(id: api.social_id, token: token)
          end
        else
          raise RegistrationError.new(:social_account_taken)
        end
      end
    end

    class << self
      def find_by_social_infos(provider_name, token)
        api = social_api(provider_name, token)
        player =
          select_all(:players).
          join(:social_associations, player_id: :id).
          where(social_associations__provider: api.provider_id, social_associations__id: api.social_id).
          first
        raise SessionError.new(:social_account_unknown) unless player
        [player, api]
      end

      def register(provider_name, token, nickname)
        api = social_api(provider_name, token)
        player = new(nickname: nickname, first_name: api.first_name, last_name: api.last_name)
        socass = SocialAssociation.new(provider: api.provider_id, id: api.social_id, token: token)

        DB.transaction(isolation: :repeatable, retry_on: [Sequel::SerializationFailure]) do
          if socass.valid?
            if player.valid?
              player.save_changes
              player.add_social_association(socass)
            else
              if player.errors[:nickname].include?('doesn\'t match')
                raise RegistrationError.new(:nickname_format_error)
              else
                raise RegistrationError.new(:nickname_taken)
              end
            end
          else
            raise RegistrationError.new(:social_account_taken)
          end
        end

        [player, api]
      end

      def social_api(provider_name, token)
        api = SocialAPI.for(provider_name, token)
        raise SocialAPIError.new(:invalid_oauth2_provider) unless api
        raise SocialAPIError.new(:invalid_oauth2_token)    unless api.valid?
        api
      end
    end
  end
end
