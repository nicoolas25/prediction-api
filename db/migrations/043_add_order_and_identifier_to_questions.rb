Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :identifier, String, null: true
      add_column :order, String, null: true
    end
  end
end
