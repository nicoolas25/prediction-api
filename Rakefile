require 'logger'
require 'active_support'
require 'active_support/deprecation'
require 'active_support/core_ext/numeric'

# Load the other tasks
Dir['./lib/tasks/*.rake'].each { |path| load path }

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
