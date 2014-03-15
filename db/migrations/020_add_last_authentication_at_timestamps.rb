Sequel.migration do
  change do
    add_column :last_authentication_at, :shared_at, DateTime
  end
end
