set :environment_variable, 'RACK_ENV'

every 10.minutes do
  rake "test:whenever"
end
