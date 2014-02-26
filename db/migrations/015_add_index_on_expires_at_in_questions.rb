Sequel.migration do
  change do
    alter_table(:questions) do
      add_index :expires_at, name: :expires_at_questions_index
    end
  end
end
