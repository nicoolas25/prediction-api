Sequel.migration do
  change do
    alter_table(:players) do
      add_column :first_name, String, size: 40
      add_column :last_name, String, size: 40
    end
  end
end
