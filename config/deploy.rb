# config valid only for current version of Capistrano
lock '3.6.1'

require 'capistrano-db-tasks'

module Database
  class Base
    def postgresql?
      %w(postgresql pg postgis).include? @config['adapter']
    end
  end
end

set :application, 'recipes'
set :repo_url, 'https://github.com/votiakov/rec-sear-api.git    '

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "www/#{fetch(:application)}/#{fetch(:stage)}/api"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml config/sidekiq.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

# Default value for default_env is {}
# set :default_env, :staging

# Default value for keep_releases is 5
# set :keep_releases, 5

# set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :bundle_path, -> { shared_path.join('bundle') }
# set :rbenv_type, :system
# set :rbenv_ruby, '2.2.1'
# # set :rbenv_ruby, 'jruby-1.7.16.1'
# set :rbenv_prefix, '/usr/local/rbenv/bin/rbenv exec'
# set :default_environment, {
#   'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
# }

set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }


set :sidekiq_config, File.join(shared_path, 'config', 'sidekiq.yml')


# DB and ASSETS sync
# if you want to remove the local dump file after loading
set :db_local_clean, true

# if you want to remove the dump file from the server after downloading
set :db_remote_clean, true

# if you want to exclude table from dump
set :db_ignore_tables, []

# if you want to exclude table data (but not table schema) from dump
# set :db_ignore_data_tables, ["versions"]

# If you want to import assets, you can change default asset dir (default = system)
# This directory must be in your shared directory on the server
set :assets_dir, %w(public/uploads)
set :local_assets_dir, 'public'

# if you want to work on a specific local environment (default = ENV['RAILS_ENV'] || 'development')
# set :locals_rails_env, "production"

# if you are highly paranoid and want to prevent any push operation to the server
set :disallow_pushing, true

# if you prefer bzip2/unbzip2 instead of gzip
# set :compressor, :bzip2
# ------------------------------------------------------

namespace :db do
  desc "Run rake db:reset"
  task :reset do
    # run "cd #{current_path} && #{fetch(:rbenv_prefix)} bundle exec rake db:reset"
    on roles(:db), in: :sequence do
      within current_path do
        execute :rake, "db:reset RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

  desc "Run rake db:seed"
  task :seed do
    # run "cd #{current_path} && #{fetch(:rbenv_prefix)} bundle exec rake db:reset"
    on roles(:db), in: :sequence do
      within current_path do
        execute :rake, "db:seed RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end

end


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :migrate, 'db:create'

end
