Sequel.migration do
  change do
    create_table(:friendships) do
      Bignum  :left_id,  null: false
      Bignum  :right_id, null: false
      Integer :provider, null: false

      primary_key [:left_id, :right_id, :provider], name: :friendships_pkey
      foreign_key [:left_id],  :players, on_delete: :cascade
      foreign_key [:right_id], :players, on_delete: :cascade
    end
  end
end
