set :environment_variable, 'RACK_ENV'
set :ruby_v, '2.1.1'

job_type :rake,
  "source /etc/profile.d/chruby.sh && chruby :ruby_v && cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"

every 10.minutes do
  rake "test:whenever"
end

every 1.day, at: '00:35am' do
  rake "backup:dropbox"
end
