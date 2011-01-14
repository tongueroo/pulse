set :keep_releases, 5
set :application,   'pulse'
set :repository,    'git@github.com:tongueroo/pulse.git'
set :deploy_to,     "/data/#{application}"
set :scm,           :git
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true # required for svn+ssh:// andf git:// sometimes

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, lambda { source.query_revision(revision) { |cmd| capture(cmd) } }

set :user, 'root'
set :runner, 'root'
set :branch, ENV['BRANCH'] || 'master'

task :production do
  set :rails_env, 'production'
  role :db,  'usolo.loc', :primary => true
  role :web, 'usolo.loc'
  role :app, 'usolo.loc'
end

namespace :deploy do
  task :restart, :roles => :app do
    sudo "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :gems do
  desc "gems install"
  task :install, :roles => [:app] do
    run "cd #{latest_release} && bundle install"
  end
end

after "deploy:update_code", "gems:install"