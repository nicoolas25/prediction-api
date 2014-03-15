Sequel.migration do
  change do
    add_column :players,        :shared_at, DateTime
    add_column :badges,         :shared_at, DateTime
    add_column :participations, :shared_at, DateTime
  end
end
