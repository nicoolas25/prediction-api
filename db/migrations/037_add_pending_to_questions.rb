Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :pending, TrueClass, default: false
    end
  end
end
