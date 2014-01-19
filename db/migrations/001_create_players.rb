Sequel.migration do
  change do
    create_table(:players) do
      primary_key :id, type: Bignum
      String :nickname, null: false, size: 30, unique: true
      String :token, null: false, size: 30
      DateTime :token_expiration, null: false

      index :token, unique: true
    end

    create_table(:social_associations) do
      Integer :provider, null: false
      String  :id, null: false
      Bignum  :player_id, null: false
      String  :token, null: false

      primary_key [:provider, :id, :player_id], name: :social_associations_pk
    end
  end
end
