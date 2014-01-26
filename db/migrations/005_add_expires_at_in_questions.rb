Sequel.migration do
  up do
    add_column :questions, :expires_at, DateTime

    from(:questions).update(expires_at: Time.now)

    alter_table(:questions) do
      set_column_not_null :expires_at
    end
  end

  down do
    drop_column :questions, :expires_at
  end
end
