
set :default_env,  'staging'
set :rails_env,     ENV['rails_env'] || ENV['RAILS_ENV'] || default_env

#
# Specify the RVM installation we want to use on the remote deployment
# system
#
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user

#
# After the website is deployed want bundle install executed
#
require "bundler/capistrano"

# Configuration
set :application, "mamtest"                              # Application Name
set :scm, :git
set :git_enable_submodules, 1
set :repository, "git@github.com:mojojoseph/mamtest"
set :branch, "master"
set :ssh_options, { :forward_agent => true }
set :runner, "deploy"
#set :app_server, :passenger

#
# Custom variables to set for staging and production environments
#
task :staging do
  set :user, "jbell"
  set :use_sudo, false
#  set :domain, "192.168.0.108"
  set :domain, "172.31.57.254"
  set :stage, :staging
  set :deploy_to, "/home/jbell/web/apps/#{stage}/#{application}"

  role :app, domain
  role :web, domain
  role :db, domain, :primary => true
end

task :production do
  set :user, "root"
  set :use_sudo, false
  set :domain, "webserver1.iachieved.it"
  set :stage, :production
  set :deploy_to, "/web/apps/#{stage}/#{application}"
  role :app, domain
  role :web, domain
  role :db, domain, :primary => true
end

#ROLES
 
# todo cold deploy needs to create asset pipeline?
namespace :deploy do

  desc "Start Application"
  task :start, :roles => :app do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} rails server -p3000 -d"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :publish_ipa, :roles => :app do
    puts "Publish"
  end
end

namespace :rake do 
  desc "Run a task on a remote server"
  task :invoke do 
    run ("cd #{current_release} && RAILS_ENV=#{rails_env} rake ios:insert_record")
  end
end

require 'mobile_app_manager/recipes'
