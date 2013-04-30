#
# Cookbook Name:: mytardis
# Recipe:: default
#
# Copyright (c) 2012, The University of Queensland
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the The University of Queensland nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF QUEENSLAND BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if platform?("ubuntu","debian")
  include_recipe "apt"
end
include_recipe "git"
include_recipe "mytardis::build-essential"
include_recipe "mytardis::deps"
include_recipe "mytardis::nginx"
include_recipe "mytardis::postgresql"

ohai "reload_passwd" do
  action :nothing
  plugin "passwd"
end

user "mytardis" do
  action :create
  comment "MyTardis Large Data Repository"
  system true
  supports :manage_home => true
  notifies :reload, resources(:ohai => "reload_passwd"), :immediately
end

app_dirs = [
  "/opt/mytardis",
  "/opt/mytardis/shared",
  "/opt/mytardis/shared/apps",
  "/var/lib/mytardis",
  "/var/log/mytardis"
]

app_links = {
  "/opt/mytardis/shared/data" => "/var/lib/mytardis",
  "/opt/mytardis/shared/log" => "/var/log/mytardis"
}

app_dirs.each do |dir|
  directory dir do
    owner "mytardis"
    group "mytardis"
  end
end

app_links.each do |k, v|
  link k do
    to v
    owner "mytardis"
    group "mytardis"
  end
end

cookbook_file "/opt/mytardis/shared/buildout.cfg" do
  action :create
  source "buildout.cfg"
  owner "mytardis"
  group "mytardis"
end

cookbook_file "/opt/mytardis/shared/settings.py" do
  action :create_if_missing
  source "settings.py"
  owner "mytardis"
  group "mytardis"
end

bash "install foreman" do
  code <<-EOH
  # Version 0.48 removes 'log_root' variable
  gem install foreman -v 0.47.0
  EOH
  #this fails on NeCTAR Ubuntu Lucid..
  # only_if do
  #   output = `gem list --local | grep foreman`
  #   output.length == 0
  # end
end

# Get the apps first, so they get symlinked correctly
app_symlinks = {}

deploy_revision "mytardis" do
  action :deploy
  deploy_to "/opt/mytardis"
  repository node['mytardis']['repo']
  branch node['mytardis']['branch']
  user "mytardis"
  group "mytardis"
  symlink_before_migrate(app_symlinks.merge({
      "data" => "var",
      "log" => "log",
      "buildout.cfg" => "buildout-prod.cfg",
      "settings.py" => "tardis/settings.py"
  }))
  purge_before_symlink([])
  create_dirs_before_symlink([])
  symlinks({})
  before_symlink do
    current_release = release_path

    bash "mytardis_buildout_install" do
      user "mytardis"
      cwd current_release
      code <<-EOH
        # this egg-cache directory never gets created - hopfully not a problem.
        export PYTHON_EGG_CACHE=/opt/mytardis/shared/egg-cache
        python setup.py clean
        find . -name '*.py[co]' -delete
        python bootstrap.py -v 1.7.0
        bin/buildout -c buildout-prod.cfg install
        bin/django syncdb --noinput --migrate 
        bin/django collectstatic -l --noinput 
      EOH
    end
  end
  restart_command do
    current_release = release_path

    bash "mytardis_foreman_install_and_restart" do
      cwd "/opt/mytardis/current"
      code <<-EOH
        foreman export upstart /etc/init -a mytardis -p 3031 -u mytardis -l /var/log/mytardis
        restart mytardis || start mytardis
      EOH
    end
  end
end

