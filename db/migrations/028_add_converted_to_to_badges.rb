Sequel.migration do
  change do
    add_column :badges, :converted_to, Integer
  end
end
