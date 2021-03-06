namespace :db do

  require './db/connect'

  desc "Prints current schema version"
  task :version do
    version = DB.tables.include?(:schema_info) ? DB[:schema_info].first[:version] : 0
    puts "Schema version is now: #{version}"
  end

  desc "Migrate the database if it's required"
  task :migrate, :target do |t, args|
    args.with_defaults(target: nil)

    Sequel.extension :migration
    if Sequel::Migrator.is_current?(DB, SEQUEL_MIGRATION_DIR) && !args.target
      puts "Migrations are good, nothing to do here."
    else
      puts "Migrating to #{args.target || 'the lastest version'}..."
      options = args.target ? {target: args.target.to_i} : {}
      Sequel::Migrator.run(DB, SEQUEL_MIGRATION_DIR, options)
    end

    Rake::Task['db:version'].execute
  end
end
