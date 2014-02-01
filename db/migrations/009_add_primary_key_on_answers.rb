Sequel.migration do
  up do
    alter_table(:answers) do
      add_primary_key [:prediction_id, :component_id], name: :answers_pkey
    end
  end

  down do
    alter_table(:answers) do
      drop_constraint :answers_pkey, type: :primary_key
    end
  end
end
