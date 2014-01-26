Sequel.migration do
  change do
    create_table(:questions) do
      primary_key :id, type: Bignum
      Bignum :author_id
      Integer :cristals, null: false, default: 0

      String :label_fr, size: 500, null: true
      String :label_en, size: 500, null: true

      foreign_key [:author_id], :players, key: :id, on_delete: :set_null
    end

    create_table(:components) do
      Integer :position,    null: false
      Bignum  :question_id, null: false
      Integer :kind,        null: false

      String  :label_fr,     null: true, size: 500
      String  :label_en,     null: true, size: 500
      String  :choices_fr,   null: true, text: true
      String  :choices_en,   null: true, text: true
      Integer :valid_answer, null: true

      foreign_key [:question_id], :questions, key: :id, on_delete: :cascade
      index [:question_id, :position], unique: true, name: :components_question_position_idx
    end
  end
end
