Sequel.migration do
  up do
    create_table(:extra_informations) do
      primary_key :id, type: Bignum
      hstore :content
    end

    alter_table(:social_associations) do
      add_foreign_key :extra_information_id, :extra_informations
    end
  end

  down do
    alter_table(:social_associations) do
      drop_foreign_key :extra_information_id
    end

    drop_table(:extra_informations)
  end
end
