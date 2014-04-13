Sequel.migration do
  up do
    add_column :players, :current_authentication_at, DateTime
    from(:players).update(current_authentication_at: Sequel.expr(:last_authentication_at))
  end

  down do
    drop_column :players, :current_authentication_at
  end
end
