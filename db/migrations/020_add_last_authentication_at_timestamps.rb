Sequel.migration do
  change do
    add_column :players, :last_authentication_at, DateTime
  end
end
