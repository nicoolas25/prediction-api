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
