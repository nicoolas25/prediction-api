Sequel.migration do
  change do
    alter_table(:predictions) do
      add_column :amount, Bignum, default: 0
    end

    alter_table(:questions) do
      add_column :amount, Bignum, default: 0
    end
  end
end
