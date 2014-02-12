Sequel.migration do
  change do
    alter_table(:players) do
      add_column :cristals, Integer, default: 0
    end
  end
end
