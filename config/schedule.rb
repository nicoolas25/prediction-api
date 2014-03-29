set :environment_variable, 'RACK_ENV'
set :environment, 'production'

every 10.minutes do
  rake "test:whenever"
end
