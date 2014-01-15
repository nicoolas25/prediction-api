path = File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift(path) unless $:.include?(path)

require 'mina/bundler'
require 'mina/git'
require 'mina/subdir'
require 'mina/chruby'

#
# Configuration
#

# Target configuration
set :domain,       '146.185.138.74'
set :deploy_to,    '/var/www/api'
set :shared_paths, ['log', 'pids']

# Repository configuration
set :repository,   'git@bitbucket:n25/pr-dictions.git'
set :branch,       'master'
set :subdirectory, 'api'

# Username and port to SSH.
set :user, 'n25'
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
    invoke :'subdir:select'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
  end
end

#
# Target setup
#

# When the deployment environment is created, some shared
# resources must be created.
task :setup => :environment do
  %w(log pids sockets).each do |dir|
    queue! %[mkdir -p "#{deploy_to}/shared/#{dir}"]
    queue! %[chmod g+rwx,u+rwx "#{deploy_to}/shared/#{dir}"]
  end
end
