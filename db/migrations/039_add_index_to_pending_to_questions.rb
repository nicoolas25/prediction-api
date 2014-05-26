Sequel.migration do
  change do
    alter_table(:questions) do
      add_index :pending, name: :pending_questions_index
    end
  end
end
