require 'mina/bundler'
require 'mina/git'
require 'mina/chruby'

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
# Database
#

namespace :db do
  desc "Migrate the database."
  task :migrate => :environment do
    queue %{
      echo "-----> Migrating database" &&
      #{echo_cmd %[rake db:migrate]}
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
