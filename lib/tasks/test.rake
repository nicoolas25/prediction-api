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
