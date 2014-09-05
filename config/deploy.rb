#========================
#CONFIG
#========================
set :application, "oneplus"
#========================
#CONFIG
#========================
require           "capistrano-offroad"
offroad_modules   "defaults", "supervisord"
set :repository,  "git@github.com:pomeo/#{application}.git"
set :supervisord_start_group, "pomeo"
set :supervisord_stop_group, "pomeo"
set :deploy_to, "/home/pomeo/www"
set :deploy_user, "pomeo"
set :deploy_group,"pomeo"
#========================
#ROLES
#========================
role :app,        "oneplus.sovechkin.com"

after "deploy:create_symlink", "deploy:go_compile", "deploy:restart"

namespace :deploy do
    desc "Compile"
    task :go_compile do
      run "cd #{current_path} && go build src/oneplus.go"
    end
  end
