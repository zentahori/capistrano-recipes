set_default :create_database_yaml, false

set_default(:database_adapter, "sqlite3")
set_default(:database_host, "localhost")
set_default(:database_user) { application }
set_default(:database_name) { "#{application}_production" }
set_default(:database_password) { production_password }

namespace :database do

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    if create_database_yaml
      try_sudo "mkdir -p #{shared_path}/config"
      sudo "chown #{user} #{shared_path}/config"
      template "database.yml.erb", "#{shared_path}/config/database.yml"
    else
      logger.info "Configured to not create database.yml file"
    end
  end
  after "deploy:setup", "database:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    if database_adapter == 'sqlite3'
      run "#{try_sudo} mkdir -p #{shared_path}/db && #{try_sudo} chown -R #{user} #{shared_path}/db && #{try_sudo} chmod 750 #{shared_path}/db"
    end
    run "#{try_sudo} ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "database:symlink"

end
