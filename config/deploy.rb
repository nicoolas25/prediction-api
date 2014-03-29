require 'mina/bundler'
require 'mina/git'
require 'mina/chruby'
require 'mina/whenever'

#
# Configuration
#

# Target configuration
set :domain,       '146.185.138.74'
set :deploy_to,    '/var/www/api'
set :shared_paths, ['log', 'pids', 'config/database.yml']

# Repository configuration
set :repository,   'git@bitbucket:n25/pr-dictions.git'
set :branch,       'master'

# Username and port to SSH.
set :user, 'prediction'
set :port, '25022'

# Set the rack environment
set :rack_env, 'production'

# Set whenever required variables
set :rails_env, rack_env
set :domain, 'prediction-api'

#
# Environment
#

# The environment on the target is using chruby,
# the application will use Ruby 2.1.0 since the target
# have only one thread available.
task :environment do
  invoke :'chruby[ruby-2.1.0]'
end

#
# Deployment
#

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'db:migrate'
    invoke :'whenever:update'

    to :launch do
      queue %[
        if [ -e #{deploy_to}/shared/pids/puma.pid ] ; then
          echo "-----> Restarting puma" &&
          #{echo_cmd %[kill -USR2 `cat #{deploy_to}/shared/pids/puma.pid`]}
        else
          echo "-----> Starting puma" &&
          #{echo_cmd %[bundle exec puma -C ./config/puma.rb]}
        fi
      ]
    end
  end
end

#
# Fixing
#

namespace :fixing do
  desc "Run the associated rake task"
  task :amounts_and_players => :environment do
    queue %{
      echo "-----> Fixing amount and players" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[RACK_ENV=#{rack_env} bundle exec rake fixing:amounts_and_players]}
    }
  end


end

#
# Database
#

namespace :db do
  desc "Migrate the database."
  task :migrate => :environment do
    queue %{
      echo "-----> Migrating database" &&
      #{echo_cmd %[RACK_ENV=#{rack_env} bundle exec rake db:migrate]}
    }
  end

  desc "Cleanup the existing data."
  task :clean => :environment do
    queue %{
      echo "-----> Cleaning the database data" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[RACK_ENV=#{rack_env} bundle exec rake db:clean]}
    }
  end

  desc "Cleanup the test players."
  task :clean_test_players => :environment do
    queue %{
      echo "-----> Cleaning the test players" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[RACK_ENV=#{rack_env} bundle exec rake db:clean_test_players]}
    }
  end
end

#
# Console
#

namespace :remote do
  desc "Open a ruby console"
  task :console => :environment do
    queue %{
      echo "-----> Lauching the console" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[RACK_ENV=#{rack_env} bundle exec rake console]}
    }
  end

  desc "Open a shell"
  task :shell => :environment do
    queue %{
      echo "-----> Lauching the console" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[bash]}
    }
  end

  desc "Tail the application log"
  task :log => :environment do
    queue %{
      echo "-----> Fllowing the log" &&
      #{echo_cmd %[cd #{deploy_to}/current]}
      #{echo_cmd %[tail -n 100 -f log/#{rack_env}.log]}
    }
  end
end

#
# Target setup
#

# When the deployment environment is created, some shared
# resources must be created.
task :setup => :environment do
  %w(log pids sockets config).each do |dir|
    queue! %[mkdir -p "#{deploy_to}/shared/#{dir}"]
    queue! %[chmod g+rwx,u+rwx "#{deploy_to}/shared/#{dir}"]
  end

  queue! %[touch #{deploy_to}/shared/config/database.yml]
end
