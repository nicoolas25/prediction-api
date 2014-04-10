require 'pry'

Sequel.migration do
  up do
    if tables.include?(:rankings)
      rename_table :rankings, :scorings
    end
  end

  down do
    if tables.include?(:scorings)
      rename_table :scorings, :scorings
    end
  end
end
