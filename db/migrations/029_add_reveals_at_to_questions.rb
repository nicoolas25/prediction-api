Sequel.migration do
  up do
    add_column :questions, :reveals_at, DateTime
    from(:questions).update(reveals_at: Sequel.expr(:created_at))
    alter_table(:questions) { set_column_not_null :reveals_at }
  end

  down do
    drop_column :questions, :reveals_at
  end
end
