Sequel.migration do
  up do
    # Updates on the components
    alter_table(:components) do
      add_primary_key :id, type: Bignum
      set_column_type :valid_answer, Float
    end

    create_table(:predictions) do
      primary_key :id, type: Bignum
      Bignum :question_id, null: false

      foreign_key [:question_id], :questions, key: :id, on_delete: :cascade
    end

    create_table(:answers) do
      Bignum :prediction_id, null: false
      Bignum :component_id,  null: false
      Float  :value,         null: false

      foreign_key [:prediction_id], :predictions, key: :id, on_delete: :cascade
      foreign_key [:component_id], :components, key: :id, on_delete: :set_null
    end
  end

  down do
    drop_table :answers
    drop_table :predictions

    alter_table(:components) do
      set_column_type :valid_answer, Integer
      drop_constraint :components_pkey
      drop_column :id
    end


  end
end
