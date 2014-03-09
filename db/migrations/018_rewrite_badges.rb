Sequel.migration do
  # To apply this migration, no badges should be present
  up do
    alter_table(:badges) do
      drop_constraint(:badges_pkey)
      add_column :level, Integer, null: false, default: 0
      add_column :created_at, DateTime, null: false

      add_primary_key [:player_id, :identifier, :level], name: :badges_pkey
    end
  end

  down do
    alter_table(:badges) do
      drop_constraint(:badges_pkey)
      drop_column :level
      drop_column :created_at

      add_primary_key [:player_id, :identifier], name: :badges_pkey
    end
  end
end
