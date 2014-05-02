require 'dropbox_sdk'

module BackupDropbox
  def self.upload(file, ext=nil, overwrite=true)
    filename = [ prefix, File.basename(file.path, ext), Time.now.strftime('%Y%m%d%H%M%S') ].join('-')
    filename = filename + ext if ext
    client.put_file("/#{filename}", file, overwrite)
  rescue
    logger.error "An error has occured preventing the upload: #{$!.message}\n#{$!.backtrace}"
    nil
  end

  def self.get_token
    flow = DropboxOAuth2FlowNoRedirect.new(key, secret)
    url  = flow.start()
    puts "1. Go to: #{url}"
    puts '2. Click "Allow" (you might have to log in first)'
    puts '3. Copy the authorization code'
    print 'Enter the authorization code here: '
    code = gets.strip
    access_token, _ = flow.finish(code)
    access_token
  end

  def self.client
    @client ||= DropboxClient.new(token)
  end

  def self.logger
    @logger ||= Logger.new('./log/backup-dropbox.log', 5, 100.megabytes)
  end

  def self.config
    env = ENV['RACK_ENV'] || 'app'
    @config ||= YAML.load_file('./config/dropbox.yml')[env]
  end

  def self.token
    config['token']
  end

  def self.key
    config['key']
  end

  def self.secret
    config['secret']
  end

  def self.prefix
    config['prefix']
  end
end
