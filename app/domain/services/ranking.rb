module Domain
  module Services
    class Ranking
      def initialize
        Ranking.prepare
      end

      def players
        @players ||= Domain::Player.dataset.
          select_append(:s__score, :s__player_id, :r__rank).
          join(:scorings___s, player_id: :id).
          join(:rankings___r, player_id: :player_id).
          order(Sequel.desc(:s__score), Sequel.asc(:s__player_id)).
          eager(:social_associations).
          all
      end

      def friends(player)
        @friends ||= player.circle_dataset.
          select_append(:s__score, :s__player_id, :r__rank).
          join(:scorings___s, player_id: :players__id).
          join(:rankings___r, player_id: :player_id).
          order(Sequel.desc(:s__score), Sequel.asc(:s__player_id)).
          eager(:social_associations).
          all
      end

      def score_for(player)
        player.values[:score]
      end

      def rank_for(player)
        player.values[:rank]
      end

      def self.rank(player)
        result = DB[:rankings].where(player_id: player.id).select(:rank).first
        result.try{ |r| r[:rank] }
      end

      def self.update(participations_dataset)
        unless prepare
          DB[:scorings].
            from(:scorings___s, participations_dataset.select(:player_id, :winnings).as(:t1)).
            where(s__player_id: :t1__player_id).
            update(score: Sequel.expr(:score) + Sequel.expr(:t1__winnings))
          update_rankings
        end
      end

      def self.ensure_player_presence(player)
        unless prepare
          DB.transaction do
            unless DB[:scorings].where(player_id: player.id).any?
              DB[:scorings].insert(player_id: player.id, score: 0)
            end

            unless DB[:rankings].where(player_id: player.id).any?
              DB[:rankings].insert(player_id: player.id, rank: DB[:rankings].count + 1)
            end
          end
        end
      end

      def self.prepare
        prepare_scorings && prepare_rankings
      end

      def self.clean
        clean_rankings
        clean_scorings
      end

      def self.prepare_rankings
        unless DB.tables.include?(:rankings)
          DB.create_table?(:rankings) do
            foreign_key :player_id, :players, key: :id, on_delete: :cascade
            Integer :rank
            Integer :delta, default: 0
          end

          DB << 'CREATE INDEX rankings_player_id_index ON rankings USING btree(player_id);'
        end

        update_rankings

        true
      end

      def self.update_rankings
        # Uses the order on scorings to compute the orders
        DB.transaction do
          DB.drop_table?(:rankings_snapshot)
          DB << 'select player_id, row_number() over (order by score desc, player_id asc) as rank into rankings_snapshot from scorings;'
          DB << 'truncate table rankings;'
          DB << 'insert into rankings select * from rankings_snapshot;'
        end
      end

      def self.prepare_scorings
        unless DB.tables.include?(:scorings)
          DB.create_table?(:scorings) do
            foreign_key :player_id, :players, key: :id, on_delete: :cascade
            Integer :score
          end

          DB << 'CREATE INDEX scorings_score_player_id_index ON scorings USING btree(score, player_id DESC);'
          DB << 'CREATE INDEX scorings_player_id_index ON scorings USING btree(player_id);'

          # Fill the table with players data
          scores_query = Domain::Player.dataset.
            select(:id, Sequel.function(:coalesce, Sequel.function(:sum, :p__winnings), 0).as(:score)).
            join_table(:left, :participations___p, player_id: :id).
            group(:id)
          DB[:scorings].insert([:player_id, :score], scores_query)
          true
        end
      end

      def self.clean_rankings
        DB.drop_table?(:rankings)
      end

      def self.clean_scorings
        DB.drop_table?(:scorings)
      end
    end
  end
end
