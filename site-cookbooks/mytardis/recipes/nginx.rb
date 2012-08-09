#
# Cookbook Name:: mytardis
# Recipe:: nginx
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

include_recipe "iptables"

if platform?("redhat","centos")
  remote_file "/var/tmp/nginx-repo.rpm" do
    source "http://nginx.org/packages/rhel/6/noarch/RPMS/nginx-release-rhel-6-0.el6.ngx.noarch.rpm"
  end

  rpm_package "/var/tmp/nginx-repo.rpm"
  
  yum_package "nginx" do
    if system("sysctl hw.cpu64bit_capable > /dev/null 2>&1")
      arch "x86_64"
    else
      arch "i386"
    end
    action [:install, :upgrade]
  end  
end

if platform?("ubuntu","debian")
   file "/etc/apt/sources.list.d/nginx-stable-lucid.list" do
      content <<-EOH
      deb http://nginx.org/packages/ubuntu/ lucid nginx
      deb-src http://nginx.org/packages/ubuntu/ lucid nginx
      EOH
      mode "644"
      action :create_if_missing
   end
   execute "apt-get update"
   
   package "nginx" do
     options "--force-yes"
     action [:install, :upgrade]
   end   
end

service "nginx" do
  action [:enable, :start]
  supports :restart => true, :reload => true
end

file "/etc/nginx/conf.d/default.conf" do
    # This file gets created if we install an old nginx first. It shows a 'welcome to nginx' page.
    action :delete
end

cookbook_file "/etc/nginx/conf.d/mytardis.conf" do
  action :create
  source "nginx_site.conf"
  mode "644"
  notifies :reload, "service[nginx]"
end

iptables_rule "ssh"
iptables_rule "http"
iptables_rule "https"

