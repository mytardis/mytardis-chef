#
# Cookbook Name:: mytardis
# Recipe:: nginx
#
# Copyright 2012, The University of Queensland
#
# All rights reserved - Do Not Redistribute
#
include_recipe "iptables"

remote_file "/var/tmp/nginx-repo.rpm" do
  source "http://nginx.org/packages/rhel/6/noarch/RPMS/nginx-release-rhel-6-0.el6.ngx.noarch.rpm"
end

rpm_package "/var/tmp/nginx-repo.rpm"

package "nginx" do
  action :upgrade
end

service "nginx" do
  action [:enable, :start]
  supports :restart => true, :reload => true
end

cookbook_file "/etc/nginx/conf.d/mytardis.conf" do
  action :create
  source "nginx_site.conf"
  notifies :reload, "service[nginx]" 
end

iptables_rule "http"
iptables_rule "https"

