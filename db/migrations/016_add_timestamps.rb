Sequel.migration do
  up do
    add_column :players, :created_at, DateTime
    add_column :participations, :created_at, DateTime
    add_column :questions, :solved_at, DateTime

    from(:players).update(created_at: Time.now)
    from(:participations).update(created_at: Time.now)
    from(:questions).where(answered: true).update(solved_at: Time.now)

    alter_table(:players) { set_column_not_null :created_at }
    alter_table(:participations) { set_column_not_null :created_at }
  end

  down do
    drop_column :questions, :solved_at
    drop_column :participations, :created_at
    drop_column :players, :created_at
  end
end
