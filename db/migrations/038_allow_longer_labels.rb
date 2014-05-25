Sequel.migration do
  change do
    alter_table(:questions) do
      set_column_type :label_dev, 'varchar(500)'
      set_column_type :label_es,  'varchar(500)'
      set_column_type :label_pt,  'varchar(500)'
    end

    alter_table(:components) do
      set_column_type :label_dev, 'varchar(500)'
      set_column_type :label_es,  'varchar(500)'
      set_column_type :label_pt,  'varchar(500)'
    end
  end
end
