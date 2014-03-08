Sequel.migration do
  change do
    create_table(:badges) do
      Bignum  :player_id, null: false
      String  :identifier, null: false
      Integer :count, null: false, default: 0

      primary_key [:player_id, :identifier], name: :badges_pkey
      foreign_key [:player_id],  :players, on_delete: :cascade
    end
  end
end
