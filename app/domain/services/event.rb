require 'set'

module Domain
  module Services
    class Event
      def initialize(player, before_datetime, after_datetime)
        @player = player
        @before = before_datetime || Time.now
        @after  = after_datetime  || Time.now.at_midnight
      end

      def events
        return @events if @events

        results  = participations_creation_grouped.map{ |q| [q.values[:last_participation_at], q]}
        results += participations_solving_grouped.map{ |q| [q.solved_at, q]}
        results += friends_creation.eager(:social_associations).all.map{ |f| [f.created_at, f] }
        results += badges_creation.eager(player: :social_associations).all.map{ |b| [b.created_at, b] }
        @events  = results.sort_by!(&:first).map!(&:last).reverse!
      end

      def events_count
        participations_creation.count +
          participations_solving.count +
          friends_creation.count +
          badges_creation.count
      end

      def have_a_participation?(question)
        participations.member?(question.id)
      end

    private

      def friends(ids)
        Domain::Player.where(id: ids).eager(:social_associations).all.each_with_object({}) do |friend, hash|
          hash[friend.id] = friend
        end
      end

      def friends_ids
        @friends_ids ||= (@player.friends_dataset.select(:id).all.map(&:id) << @player.id)
      end

      def filter_dataset(attribute, dataset)
        dataset.
          where(Sequel.expr(attribute) >= @after).
          where(Sequel.expr(attribute) < @before)
      end

      def filter_dataset_in(begin_attribute, end_attribute, dataset)
        dataset.exclude(
          (Sequel.expr(begin_attribute) >= @before) |
          (Sequel.expr(end_attribute) <= @after))
      end

      def friends_creation
        filter_dataset(:players__created_at, @player.friends_dataset)
      end

      # Questions answered by player or by its friends
      # The question have two extra attributes:
      #   - last_participation_at: the date of the last participation
      #   - participant_ids: the list of participant for this question
      def participations_creation
        filter_dataset(
          :last_participation_at,
          ::Domain::Question.dataset.from(
            filter_dataset_in(
              :questions__reveals_at, :questions__expires_at,
              ::Domain::Question.dataset.
                select_all(:questions).
                select_append(
                  Sequel.function(:max, :participations__created_at).as(:last_participation_at),
                  Sequel.function(:string_agg, Sequel.expr(:participations__player_id).cast_string, ' ').as(:participant_ids)).
                join(:participations, question_id: :id, player_id: friends_ids).
                group(:questions__id)
            )
          )
        )
      end

      # Questions solved and correctly answered by player or by its friends
      # The question have one extra attributes:
      #   - participant_ids: the list of participant for this question
      def participations_solving
        filter_dataset(
          :questions__solved_at,
          ::Domain::Question.
            select_all(:questions).
            select_append(
              Sequel.function(:string_agg, Sequel.expr(:participations__player_id).cast_string, ' ').as(:participant_ids),
              Sequel.function(:avg, :participations__winnings).as(:average_winnings),
              :questions__answered___solved).
            join(:participations, question_id: :id, player_id: friends_ids).
            where(questions__answered: true).
            where(Sequel.expr(:participations__winnings) > 0).
            group(:questions__id)
        )
      end

      def badges_creation
        filter_dataset(:badges__created_at, ::Domain::Badge.dataset.visible.where(player_id: friends_ids))
      end

      def participations_creation_grouped
        @_pc ||= inject_participants(participations_creation)
      end

      def participations_solving_grouped
        @_ps ||= inject_participants(participations_solving)
      end

      # Doing the ORM job here
      def inject_participants(dataset)
        questions = dataset.all
        ids = extract_participant_ids(questions).to_a
        candidates = friends(ids)
        questions.each do |question|
          question.participants = question.values[:participant_ids].map{ |id| candidates[id] }
        end
        questions
      end

      # It also coerce the values in participant_ids
      def extract_participant_ids(questions)
        questions.each_with_object(Set.new) do |question, ids|
          raw_ids = []
          question.values[:participant_ids].split(' ').each do |id|
            unless id.blank?
              ids << id.to_i
              raw_ids << id.to_i
            end
          end
          question.values[:participant_ids] = raw_ids
        end
      end

      def participations
        return @participations if @participations

        participations = Set.new
        question_ids = events.map do |e|
          if e.kind_of?(::Domain::Question)
            e.id
          end
        end.compact.uniq
        @player.participations_dataset.
          where(question_id: question_ids).
          select(:question_id).
          all.
          each { |p| participations << p.question_id }

        @participations = participations
      end

      # LATER
      # def questions_creation
      # end
    end
  end
end
