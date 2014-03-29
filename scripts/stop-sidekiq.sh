#!/bin/bash

# This script is intended to work with monit.

source /etc/profile.d/chruby.sh
chruby 2.1.0

pid_file=/var/www/api/shared/pids/sidekiq.pid

cd "/var/www/api/current"
bundle exec sidekiqctl stop $pidfile 10