load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks

=begin
namespace :deploy do

  task :start, :roles => :app do
    run "rm -rf /home/#{user}/public_html;ln -s #{current_path}/public /home/#{user}/public_html"
  end

  task :restart, :roles => :app do
    run "#{current_path}/script/process/reaper --dispatcher=dispatch.fcgi"
  end

end
=end



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
    run "ln -s #{deploy_to}/shared/pak_data_id_file #{deploy_to}/current/lib/data/pak_data_id_file"
    run "ln -s #{deploy_to}/shared/pak_data_id_file #{deploy_to}/current/lib/data/af_data_id_file"
    run "chmod +x #{deploy_to}/current/lib/scrapers/af_gatherer.rb"
    run "chmod +x #{deploy_to}/current/lib/scrapers/af_scraper.rb"
    run "chmod +x #{deploy_to}/current/lib/scrapers/pak_scraper.rb"
  end
end

