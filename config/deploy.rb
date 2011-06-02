set :application, "ngo-project"
set :domain, "themasheraproject.org"                           # The URL for your app
set :user, "themasheraproject"                                 # Your HostingRails username
set :scm_username, "jekozyra"                   #if http

# For a Subversion repository
# set :repository,  "svn+ssh://#{user}@#{domain}/home/#{user}/svn/#{application}/trunk"   # The repository location for svn+ssh access
# set :repository, "http://svn.#{domain}/svn/#{application}/trunk"                      # The repository location for http access from the server
# set :local_repository, "http://svn.#{domain}:port/svn/#{application}/trunk"           # The repository location for http access from the local machine (this could be different from above if you use ssh port forwarding for svn access

# For a Git repository
# See http://www.hostingrails.com/forums/wiki_thread/59 for more info on Git and HostingRails
set :scm_username, "jekozyra"                   #if http
set :repository, "git@github.com:#{scm_username}/#{application}.git"                # Or any other valid git clone path
set :scm, :git

set :use_sudo, false                                  # HostingRails users don't have sudo access
set :deploy_to, "/home/#{user}/#{application}"   # Where on the server your app will be deployed
set :deploy_via, :checkout                            # For this tutorial, svn checkout will be the deployment method, but check out :remote_cache in the future
set :group_writable, false                            # By default, Capistrano makes the release group-writable. You don't want this with HostingRails
# set :mongrel_port, "4444"                           # Mongrel port that was assigned to you
# set :mongrel_nodes, "4"                             # Number of Mongrel instances for those with multiple Mongrels

default_run_options[:pty] = true
# Cap won't work on windows without the above line, see
# http://groups.google.com/group/capistrano/browse_thread/thread/13b029f75b61c09d
# Its OK to leave it true for Linux/Mac

#ssh_options[:keys] = %w(/Path/To/id_rsa)              # If you are using ssh_keys

role :app, domain
role :web, domain
role :db,  domain, :primary => true

