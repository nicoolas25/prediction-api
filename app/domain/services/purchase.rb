module Domain
  class TransactionNotFoundError < Error ; end
  class UnknownProductError < Error ; end

  module Services
    class Purchase
      VALID_PRODUCT_IDS = [
        'cristals_100',
        'cristals_250',
        'cristals_500',
        'cristals_1000',
        'cristals_2000',
        'bonus_1',
        'bonus_2',
        'bonus_3',
        'bonus_4'
      ].freeze

      def initialize(player, provider, payload)
        @player = player
        @payment_api = PaymentAPI.for(provider, payload)
      end

      def apply!
        unless @payment_api.transaction_id
          raise TransactionNotFoundError.new(:transaction_not_found)
        end

        unless VALID_PRODUCT_IDS.include?(@payment_api.product_id)
          raise UnknownProductError.new(:unknown_product_id)
        end

        ::Domain::Payment.create_from(@player, @payment_api) do
          __send__(@payment_api.product_id)
        end
      end

      # Define cristals methods
      [100, 250, 500, 1000, 2000].each do |count|
        define_method("cristals_#{count}") do
          @player.increment_cristals_by!(count)
        end
      end

      # Define bonus methods
      [1, 2, 3, 4].each do |count|
        define_method("bonus_#{count}") do
          ::Domain::Bonuses.modules.keys.each do |identifier|
            count.times do
              ::Domain::Bonus.create(player_id: @player.id, identifier: identifier)
            end
          end
        end
      end
    end
  end
end
