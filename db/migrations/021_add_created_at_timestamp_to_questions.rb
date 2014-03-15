Sequel.migration do
  up do
    add_column :questions, :created_at, DateTime
    from(:questions).where(answered: true).update(created_at: Sequel.expr(:solved_at))
    from(:questions).where(answered: false).update(created_at: Time.now)
    alter_table(:questions) { set_column_not_null :created_at }
  end

  down do
    drop_column :questions, :created_at
  end
end
