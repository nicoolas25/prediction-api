Sequel.migration do
  up do
    run 'CREATE INDEX players_lower_nickname_idx ON players (lower(nickname));'
  end

  down do
    run 'DROP INDEX players_lower_nickname_idx;'
  end
end
