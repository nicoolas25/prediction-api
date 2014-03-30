Sequel.migration do
  change do
    create_table(:bonuses) do
      primary_key :id, type: Bignum
      Bignum :player_id, null: false
      Bignum :prediction_id, null: true
      String :identifier, null: false

      index       [:player_id, :prediction_id], name: :bonuses_participation_index
      foreign_key [:player_id], :players, on_delete: :cascade
      foreign_key [:prediction_id], :predictions, on_delete: :cascade
    end
  end
end
