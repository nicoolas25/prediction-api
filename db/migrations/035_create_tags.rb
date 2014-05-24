Sequel.migration do
  change do
    create_table(:tags) do
      primary_key :id, type: Bignum
      String :keyword, null: false, size: 30
      index :keyword, unique: true
    end

    create_join_table(
      { question_id: {table: :questions, type: Bignum},
        tag_id: {table: :tags, type: Bignum} },
      { index_options: {unique: true} }
    )
  end
end
