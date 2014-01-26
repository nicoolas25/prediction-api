Sequel.migration do
  change do
    alter_table(:predictions) do
      add_column :cksum, String, null: false, size: 100
    end

    create_table(:participations) do
      Bignum  :player_id,     null: false
      Bignum  :prediction_id, null: false
      Bignum  :question_id,   null: false
      Integer :stakes,        null: false
      Integer :winnings,      null: true

      primary_key [:player_id, :prediction_id], name: :participations_pk
      foreign_key [:player_id],     :players, on_delete: :cascade
      foreign_key [:prediction_id], :players, on_delete: :cascade
      foreign_key [:question_id],   :players, on_delete: :cascade
    end
  end
end
