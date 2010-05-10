load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks

# ========================
# For mod_rails apps
# ========================
# This assumes that your database.yml file is NOT in subversion,
# but instead is in your deploy_to/shared directory. Database.yml
# files should *never* go into subversion for security reasons.

namespace :deploy do
   task :start, :roles => :app do
     run "touch #{deploy_to}/current/tmp/restart.txt"
   end
   
   task :restart, :roles => :app do
     run "touch #{deploy_to}/current/tmp/restart.txt"
   end
 
   task :after_symlink, :roles => :app do
     run "rm -f ~/public_html;ln -s #{deploy_to}/current/public ~/public_html"
     run "ln -s #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"
   end
 end