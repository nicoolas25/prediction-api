require 'logger'
require 'active_support/deprecation'
require 'active_support/core_ext/numeric'

desc "Load a console"
task :console do
  require './api'
  ARGV.clear
  if ENV['RACK_ENV'] == 'production'
    require 'irb'
    require 'irb/completion'
    IRB.start
  else
    require 'pry'
    Pry.start
  end
end

namespace :backup do
  desc "Save the database content to the dropbox account"
  task :dropbox do
    require './db/connect'
    require './lib/backup_dropbox'

    database = DB.opts[:database]
    host     = DB.opts[:host]
    port     = DB.opts[:port]
    user     = DB.opts[:user]
    password = DB.opts[:password]
    prefix   = password ? "PGPASSWORD=#{password} " : ''
    target   = '/tmp/prediction-database.gz'

    %x{#{prefix} pg_dump -U#{user} -h #{host} -p #{port} #{database} | gzip > #{target}}

    if $?.exitstatus == 0
      BackupDropbox.upload(File.new(target), '.gz')
      puts "Backup sent sucessfully to Dropbox account."
    else
      message = "Dump failed with status #{$?.exitstatus}."
      BackupDropbox.logger.error message
      puts message
    end
  end
end

namespace :db do
  ROOT_PATH = File.dirname(__FILE__)
  MIGRATION_DIR = File.join(ROOT_PATH, 'db', 'migrations')

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
    if Sequel::Migrator.is_current?(DB, MIGRATION_DIR) && !args.target
      puts "Migrations are good, nothing to do here."
    else
      puts "Migrating to #{args.target || 'the lastest version'}..."
      options = args.target ? {target: args.target.to_i} : {}
      Sequel::Migrator.run(DB, MIGRATION_DIR, options)
    end

    Rake::Task['db:version'].execute
  end
end

namespace :fixing do
  desc "Update the amount and the player count"
  task :amounts_and_players do
    require './api'

    Domain::Question.all.each do |q|
      q.refresh_players!
      q.refresh_amount!
    end

    Domain::Prediction.all.each do |p|
      p.refresh_players!
      p.refresh_amount!
    end
  end

  desc "Run hooks to get badges"
  task :badges_hooks do
    require './api'

    # Destroy all badges - be careful
    Domain::Badge.dataset.destroy

    Domain::Participation.all.each do |participation|
      Domain::Badges.run_hooks(:after_participation, participation)
      unless participation.winnings.nil?
        if participation.win?
          Domain::Badges.run_hooks(:after_winning, participation)
        else
          Domain::Badges.run_hooks(:after_loosing, participation)
        end
      end
    end
  end
end

namespace :test do
  desc "Test the reccurent tasks are running"
  task :whenever do
    logger = Logger.new('./log/test-whenever.log', 5, 100.megabytes)
    logger.info '==> Whenever is running'
    logger.info "Time.now: #{Time.now.strftime('%c')}"
    logger.info "RACK_ENV: #{ENV['RACK_ENV']}"
    logger.info '==> done'
  end
end
