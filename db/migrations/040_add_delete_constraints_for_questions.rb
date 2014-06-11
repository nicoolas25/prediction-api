Sequel.migration do
  up do
    alter_table(:questions_tags) do
      drop_foreign_key [:question_id]
      drop_foreign_key [:tag_id]
    end

    alter_table(:questions_tags) do
      add_foreign_key [:question_id], :questions, on_delete: :cascade
      add_foreign_key [:tag_id], :tags, on_delete: :cascade
    end
  end

  down do
    alter_table(:questions_tags) do
      drop_foreign_key [:question_id]
      drop_foreign_key [:tag_id]
    end

    alter_table(:questions_tags) do
      add_foreign_key [:question_id], :questions
      add_foreign_key [:tag_id], :tags
    end
  end

end
