Sequel.migration do
  up do
    add_column :players, :auto_earn_at, DateTime
    from(:players).update(auto_earn_at: Time.now - 1.hour)
  end

  down do
    drop_column :players, :auto_earn_at
  end
end
