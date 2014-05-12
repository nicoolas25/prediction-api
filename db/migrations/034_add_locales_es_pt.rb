Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :label_pt, String, null: true, size: 30
      add_column :label_es, String, null: true, size: 30
    end

    alter_table(:components) do
      add_column :label_pt, String,   null: true, size: 30
      add_column :label_es, String,   null: true, size: 30
      add_column :choices_pt, String, null: true, text: true
      add_column :choices_es, String, null: true, text: true
    end
  end
end
