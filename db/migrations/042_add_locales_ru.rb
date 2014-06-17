Sequel.migration do
  change do
    alter_table(:questions) do
      add_column :label_ru, String, null: true, size: 500
    end

    alter_table(:components) do
      add_column :label_ru, String,   null: true, size: 500
      add_column :choices_ru, String, null: true, text: true
    end
  end
end
