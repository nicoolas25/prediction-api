# Truncate the database before each scenario
Before do
  DB.tables.each do |table_name|
    next if table_name == :schema_info
    DB[table_name].truncate(cascade: true)
  end
end
