#!/bin/bash

# This script is intended to work with monit.

chruby 2.1.0

config_file=/var/www/api/current/config/sidekiq.yml
pid_file=/var/www/api/shared/pids/sidekiq.pid
log_file=/var/www/api/shared/log/sidekiq.log

cd "/var/www/api/current"
nohup bundle exec sidekiq -e production -C $config_file -P $pidfile -r ./app/workers.rb >> $log_file 2>&1 &
