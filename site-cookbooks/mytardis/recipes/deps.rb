#
# Cookbook Name:: mytardis
# Recipe:: default
#
# Copyright 2012, The University of Queensland
#
# All rights reserved - Do Not Redistribute
#

# Ensure we have ruby-devel for the postgresql recipe
package "ruby-devel" do
  action :install
end

# The basics for Python & devel packages we need for buildout
mytardis_pkg_deps = [
  "gcc",
  "python-devel", 
  "openldap-devel", 
  "openssl-devel", 
  "libxml2-devel", 
  "libxslt-devel"
]
mytardis_pkg_deps.each do |pkg|
  package pkg do
    action :install
  end
end
