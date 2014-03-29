Sequel.migration do
  up do
    add_column :social_associations, :last_updated_at, DateTime
    from(:social_associations).update(last_updated_at: Time.now)
  end

  down do
    drop_column :social_associations, :last_updated_at
  end
end
