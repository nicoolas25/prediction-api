Sequel.migration do
  change do
    add_column :social_associations, :email,   String
    add_column :social_associations, :primary, TrueClass, default: true
    add_column :social_associations, :active,  TrueClass, default: true
    add_column :social_associations, :sharing, TrueClass, default: true
  end
end
