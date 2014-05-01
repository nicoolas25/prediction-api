Sequel.migration do
  change do
    create_table(:payments) do
      primary_key :id, type: Bignum
      String :provider,       null: false
      String :transaction_id, null: false
      String :product_id,     null: false
      Bignum :player_id,      null: true
      DateTime :created_at,   null: true

      index       [:provider, :transaction_id], name: :payments_transaction_index, unique: true
      foreign_key [:player_id], :players, on_delete: :set_null
    end
  end
end
