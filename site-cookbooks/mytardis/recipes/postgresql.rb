#
# Cookbook Name:: mytardis
# Recipe:: default
#
# Copyright 2012, The University of Queensland
#
# All rights reserved - Do Not Redistribute
#

include_recipe "postgresql::server"

# Probably don't need this, given we have IDENT security
file "/root/postgresql.passwd" do
  content node['postgresql']['password']['postgres']
end

file "/var/tmp/create_mytardis_db.sql" do
  action :create_if_missing
  owner "postgres"
  content <<-EOH
  CREATE USER mytardis;
  CREATE DATABASE mytardis OWNER mytardis;
  EOH
  notifies :run, "bash[create mytardis db]"
end

bash "create mytardis db" do
  action :nothing
  code <<-EOH
  sudo -u postgres psql < /var/tmp/create_mytardis_db.sql
  EOH
end
