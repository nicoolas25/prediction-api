# Sets the path to sidekiq.
set_default :sidekiq, -> { "#{bundle_bin} exec sidekiq" }

# Sets the path to sidekiqctl.
set_default :sidekiqctl, -> { "#{bundle_bin} exec sidekiqctl" }

# Sets a upper limit of time a worker is allowed to finish, before it is killed.
set_default :sidekiq_timeout, 10

# Sets the path to the configuration file of sidekiq
set_default :sidekiq_config, -> { "#{deploy_to}/#{current_path}/config/sidekiq.yml" }

# Sets the path to the log file of sidekiq
set_default :sidekiq_log, -> { "#{deploy_to}/#{shared_path}/log/sidekiq.log" }

# Sets the path to the pid file of a sidekiq worker
set_default :sidekiq_pidfile, -> { "#{deploy_to}/#{shared_path}/pids/sidekiq.pid" }

# Sets the sidekiq env
set_default :sidekiq_env, -> { "./app/workers.rb" }

namespace :sidekiq do
  desc "Quiet sidekiq (stop accepting new work)"
  task quiet: :environment do
    queue %[echo "-----> Quiet sidekiq (stop accepting new work)"]
    queue %{
      if [ -f #{sidekiq_pidfile} ] && kill -0 `cat #{sidekiq_pidfile}`> /dev/null 2>&1; then
        cd "#{deploy_to}/#{current_path}"
        #{echo_cmd %{#{sidekiqctl} quiet #{sidekiq_pidfile}} }
      else
        echo 'Skip quiet command (no pid file found)'
      fi
    }
  end

  desc "Stop sidekiq"
  task stop: :environment do
    queue %[echo "-----> Stop sidekiq"]
    queue %[
      if [ -f #{sidekiq_pidfile} ] && kill -0 `cat #{sidekiq_pidfile}`> /dev/null 2>&1; then
        cd "#{deploy_to}/#{current_path}"
        #{echo_cmd %[#{sidekiqctl} stop #{sidekiq_pidfile} #{sidekiq_timeout}]}
      else
        echo 'Skip stopping sidekiq (no pid file found)'
      fi
    ]
  end

  desc "Start sidekiq"
  task start: :environment do
    queue %[echo "-----> Start sidekiq"]
    queue %{
      cd "#{deploy_to}/#{current_path}"
      #{echo_cmd %[nohup #{sidekiq} -e #{rack_env} -C #{sidekiq_config} -P #{sidekiq_pidfile} -r #{sidekiq_env} >> #{sidekiq_log} 2>&1 &] }
    }
  end

  desc "Restart sidekiq"
  task :restart do
    invoke :'sidekiq:stop'
    invoke :'sidekiq:start'
  end
end
