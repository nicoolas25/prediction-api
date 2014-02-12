Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :answered, TrueClass, default: false
    end
  end
end
