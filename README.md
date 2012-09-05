Overview
========
*Written by Steve Androulakis (github user steveandroulakis) on 9th August 2012*

This Cookbook installs the current master of MyTardis - [http://github.com/mytardis/mytardis][1]

It's been tested and confirmed to work on Ubuntu 10 (Lucid), 12 (see notes below), and CentOS 6.

It's also been tested using Vagrant and the NeCTAR Research Cloud (see [http://nectar.org.au/][2]).

Download or git clone this cookbook and use it with Chef Solo or upload it to Hosted Chef (look on Chef's site for guides).

Also includes Stevage's atom app. [http://github.com/stevage][3]

This installation is very minimal (no accounts, no example data) but is enough to get you started.

Configuration
=============

This doesn't really differ from other Chef cookbook installations, so I recommend you follow their Getting Started Guide [http://wiki.opscode.com/display/chef/Fast+Start+Guide][4] which will help you setup a Chef Client Workstation (to control deployments) and a Hosted Chef account (to store cookbooks and pull them down from the server).

This guide will cover two methods. Vagrant (virtual machine on your local computer) and remote instances.

Common Configuration
-------

This part needs to be done if using Hosted chef (for Chef-Solo help go elsewhere, or if you don't know what this means then use Hosted Chef!).

Follow the Chef getting started guide linked above, then:

 1. Upload the mytardis-chef cookbook to the server
 2. Create knife roles for MyTardis

**Upload**

On your client workstation (the one with Knife installed), use:

    knife cookbook upload -o /path/to/mytardis-chef/site-cookbooks/:/path/to/mytardis-chef/cookbooks/ -a -d

Where /path/to is the path to your downloaded mytardis-chef repo (this repository).

This will upload the MyTardis recipe and its dependencies to your Hosted Chef.

**Create Knife Roles**

    knife role from file /path/to/mytardis-chef/roles/mytardis.json

Your Hosted Chef now has the cookbook, and roles and therefore all it needs to be run on an instance.

Local Deployment
-------

This is a quick and dirty guide to using Vagrant to set up a local deployment (on your laptop/desktop etc).

Follow the Vagrant Getting Started Guide: [http://vagrantup.com/v1/docs/getting-started/index.html][5]

This will walk you through getting Oracle's VirtualBox software, Vagrant and a Ubuntu Lucid OS. Follow the guide to the 'vagrant box add' step.

Note: this has also been tested with CentOS 6 via

    vagrant box add centos6 https://dl.dropbox.com/u/7225008/Vagrant/CentOS-6.3-x86_64-minimal.box

So you can run that instead of the lucid32 command from the getting started guide.

This cookbook contains sample Vagrantfile configs, one for Ubuntu, the other for CentOS. Assuming you ran the vagrant box add lucid32 command (not the CentOS one) above:

 1. Copy mytardis-chef/vagrant-config/Vagrantfile-lucid to an empty directory on your machine
 2. Rename the file to Vagrantfile
 3. Edit the Vagrantfile to suit your needs. Commands you may need to edit include 'config.vm.network :hostonly' and config.vm.boot_mode = :gui. Furthermore there are shell environment variables such as OPSCODE_USER that need to be set to your Hosted Chef account details.
 4. Type 'vagrant up'

Vagrant should initialise a new virtual machine, and start chef-client to install this cookbook. Note that this can take upwards of 30 minutes. The result should be a working MyTardis installation started.

*You may need to 'vagrant ssh' into the box and then 'ifconfig' to get the ip address of the created virtual machine then access it on the web on your machine via http://<ip_address>/*

Pause the virtual machine without killing it by typing 'vagrant halt' and 'vagrant up' to resume.

Remove the virtual machine entirely with 'vagrant destroy'. 'vagrant up' in the same directory will start another new machine.

Remote Deployment
-------

This is a guide to deploying this on a remote server. This has been tested using the NecTAR cloud (like Amazon ec2) on Ubuntu 10, 12 and CentOS 6.

Run these commands from your knife client workstation (your local machine). You may need to copy your knife.rb username.pem and client-validator.pem to ~/.chef so you can run the knife command from any directory.

For CentOS 6, where <ip> is the ip address of the target server and root is the name of your superuser account. Note: depending on your remote machine, you may need to use key authentication by inserting '-i /path/to/yourkey.pem' in the account.

    knife bootstrap <ip> -x root -r 'role[mytardis]'

For Ubuntu 10 (Lucid)

    knife bootstrap <ip> -x ubuntu --sudo -r 'rolemytardis]'

For Ubuntu 12:

    knife bootstrap <ip> -x ubuntu --sudo -d ubuntu12.04-gems -r 'role[mytardis]'

That's it! You should watch knife invoke chef on the target server and watch the deployment unfold before your eyes.

  [1]: http://github.com/mytardis/mytardis
  [2]: http://nectar.org.au/
  [3]: http://github.com/stevage
  [4]: http://wiki.opscode.com/display/chef/Fast+Start+Guide
  [5]: http://vagrantup.com/v1/docs/getting-started/index.html
