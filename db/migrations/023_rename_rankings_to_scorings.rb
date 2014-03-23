Sequel.migration do
  up do
    rename_table :rankings, :scorings if table_exists?(:rankings)
  end

  down do
    rename_table :scorings, :scorings if table_exists?(:scorings)
  end
end
