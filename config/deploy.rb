#========================
#CONFIG
#========================
set :application, "oneplus"
#========================
#CONFIG
#========================
require           "capistrano-offroad"
offroad_modules   "defaults", "supervisord"
set :repository,  "git@github.com:user/#{application}.git"
set :supervisord_start_group, "pomeo"
set :supervisord_stop_group, "pomeo"
set :deploy_to, "/home/pomeo/www"
set :deploy_user, "pomeo"
set :deploy_group,"pomeo"
#========================
#ROLES
#========================
role :app,        "oneplus.sovechkin.com"

after "deploy:create_symlink", "deploy:npm_install", "deploy:restart"
