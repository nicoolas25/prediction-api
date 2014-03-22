Sequel.migration do
  change do
    add_column :social_associations, :avatar_url, String
  end
end
