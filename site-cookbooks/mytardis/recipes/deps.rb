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

# Ensure we have ruby-devel for the postgresql recipe
if platform?("redhat","centos","fedora")
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
end

if platform?("ubuntu","debian")
  package "ruby-dev" do
    action :install
  end
  package "make" do
#:    action :install
  end

  execute "apt-get update" do
    # This isn't supposed to be required, but I (SteveB) am bored of investigating.
    # Without it, imagemagick fails to install.  
  end

# The basics for Python & devel packages we need for buildout
  mytardis_pkg_deps = [
    "gcc",
    "python-dev",
    "slapd",
    "ldap-utils", 
    "libssl-dev",
    "libxml2-dev",
    "libxslt-dev",

    "git-core",
    "imagemagick",
    "oidentd"
  ]
  # openldap-devel removed - wouldn't compile?

end


mytardis_pkg_deps.each do |pkg|
  package pkg do
    action :install
  end
end
