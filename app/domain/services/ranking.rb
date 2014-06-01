module Domain
  module Services
    class Ranking
      PAGE_SIZE = 40

      def initialize(rank=nil, limit=nil)
        @rank = rank
        @limit = limit
      end

      def players
        @players ||= begin
          ds = Domain::Player.dataset.
            select_append(:s__score, :s__player_id, :r__rank, :r__delta).
            join(:scorings___s, player_id: :id).
            join(:rankings___r, player_id: :player_id).
            where(Sequel.expr(:r__rank) >= @rank).
            order(Sequel.asc(:r__rank)).
            limit(PAGE_SIZE)

          # Ensure the limit
          ds = ds.where(Sequel.expr(:r__rank) <= @limit) if @limit

          ds.eager(:social_associations).all
        end
      end

      def friends(player)
        @friends ||= player.circle_dataset.
          select_append(:s__score, :s__player_id, :r__rank, :r__delta).
          join(:scorings___s, player_id: :players__id).
          join(:rankings___r, player_id: :players__id).
          order(Sequel.desc(:s__score), Sequel.asc(:s__player_id)).
          eager(:social_associations).
          distinct(:s__score, :s__player_id).
          all
      end

      def score_for(player)
        player.values[:score]
      end

      def rank_for(player)
        player.values[:rank]
      end

      def delta_for(player)
        player.values[:delta]
      end

      class << self
        def top
          new(1)
        end

        def arround(player)
          limit = rank(player)
          rank = [limit - (PAGE_SIZE / 2), 1].max
          new(rank)
        end

        def before(player)
          limit = rank(player) - 1
          rank = [limit - PAGE_SIZE, 1].max
          new(rank, limit)
        end

        def after(player)
          prepare
          new(rank(player) + 1)
        end

        def rank(player)
          prepare
          DB[:rankings].
            where(player_id: player.id).
            select(:rank).
            first.
            try{ |r| r[:rank] }
        end

        def rank_friends(player)
          prepare
          rank = rank(player)
          return (player.friends_dataset.count + 1) unless rank
          DB[:rankings].
            where(player_id: player.friends_dataset.select(:id)).
            where(Sequel.expr(:rank) < rank).
            count + 1
        end


        def update(participations_dataset)
          unless prepare
            DB[:scorings].
              from(:scorings___s, participations_dataset.select(:player_id, :winnings).as(:t1)).
              where(s__player_id: :t1__player_id).
              update(score: Sequel.expr(:score) + Sequel.expr(:t1__winnings))
            update_rankings
          end
        end

        def ensure_player_presence(player)
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

        def prepare
          prepare_scorings && prepare_rankings
        end

        def clean
          clean_rankings
          clean_scorings
        end

        def prepare_rankings
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

        def update_rankings
          # Uses the order on scorings to compute the orders
          DB.transaction do
            DB.drop_table?(:rankings_snapshot)
            DB << %Q{
              with s as (select player_id, row_number() over (order by score desc, player_id asc) as rank from scorings)
              select
                s.player_id,
                s.rank,
                case when r.rank is null then 0 else r.rank - s.rank end as delta
              into rankings_snapshot
              from s
              left join rankings as r on r.player_id = s.player_id;
            }
            DB << 'truncate table rankings;'
            DB << 'insert into rankings select * from rankings_snapshot;'
          end
        end

        def prepare_scorings
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

        def clean_rankings
          DB.drop_table?(:rankings)
        end

        def clean_scorings
          DB.drop_table?(:scorings)
        end
      end
    end
  end
end
