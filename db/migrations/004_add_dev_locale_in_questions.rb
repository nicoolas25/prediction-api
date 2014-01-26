Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :label_dev, String, null: true, size: 30
    end

    alter_table(:components) do
      add_column :label_dev, String,   null: true, size: 30
      add_column :choices_dev, String, null: true, text: true
    end
  end
end
