Sequel.migration do
  change do
    alter_table(:social_associations) do
      add_foreign_key [:player_id], :players, key: :id, on_delete: :cascade
    end
  end
end
