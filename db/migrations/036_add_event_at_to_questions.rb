Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :event_at, DateTime, null: true
    end
  end
end
