module Domain
  module Services
    class Ranking
      def initialize
        Ranking.prepare
      end

      def players
        @players ||= Domain::Player.dataset.
          select_append(:r__score, :r__player_id).
          join(:scorings___r, player_id: :id).
          order(Sequel.desc(:r__score), Sequel.asc(:r__player_id)).
          eager(:social_associations).
          all
      end

      def friends(player)
        @friends ||= player.circle_dataset.
          select_append(:r__score, :r__player_id).
          join(:scorings___r, player_id: :players__id).
          order(Sequel.desc(:r__score), Sequel.asc(:r__player_id)).
          eager(:social_associations).
          all
      end

      def score_for(player)
        player.values[:score]
      end

      def self.update(participations_dataset)
        unless prepare
          DB[:scorings].
            from(:scorings___r, participations_dataset.select(:player_id, :winnings).as(:t1)).
            where(r__player_id: :t1__player_id).
            update(score: Sequel.expr(:score) + Sequel.expr(:t1__winnings))
        end
      end

      def self.ensure_player_presence(player)
        prepare
        DB.transaction do
          unless DB[:scorings].where(player_id: player.id).any?
            DB[:scorings].insert(player_id: player.id, score: 0)
          end
        end
      end

      def self.prepare
        unless DB.tables.include?(:scorings)
          # Create the table
          DB.create_table?(:scorings) do
            foreign_key :player_id, :players, key: :id, on_delete: :cascade
            Integer :score
          end

          # Create indexes
          DB.run(%Q{CREATE INDEX scorings_score_player_id_index ON scorings USING btree(score, player_id DESC);})
          DB.run(%Q{CREATE INDEX scorings_player_id_index ON scorings USING btree(player_id);})

          # Fill the table with players data
          scores_query = Domain::Player.dataset.
            select(:id, Sequel.function(:coalesce, Sequel.function(:sum, :p__winnings), 0).as(:score)).
            join_table(:left, :participations___p, player_id: :id).
            group(:id)
          DB[:scorings].insert([:player_id, :score], scores_query)
          true
        end
      end

      def self.clean
        DB.drop_table?(:scorings)
      end
    end
  end
end
