module Domain
  class ExistingTransactionError < Error ; end

  class Payment < ::Sequel::Model
    unrestrict_primary_key

    many_to_one :player

    # Add creation time at creation
    def before_create
      super
      self.created_at ||= Time.now
    end

    class << self
      def exists_like?(payment_api)
        where(transaction_id: payment_api.transaction_id, provider: payment_api.provider).count > 0
      end

      # Add a new payment from a PaymentAPI object
      def create_from(player, payment_api, &block)
        DB.transaction do
          block.call
          create(
            transaction_id: payment_api.transaction_id,
            provider: payment_api.provider,
            product_id: payment_api.product_id,
            player_id: player.id)
        end
      rescue
        raise ExistingTransactionError.new(:existing_transaction)
      end
    end
  end
end
