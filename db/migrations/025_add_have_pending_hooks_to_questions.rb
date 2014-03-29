Sequel.migration do
  change do
    add_column :questions, :have_pending_hooks, TrueClass, default: true
  end
end
