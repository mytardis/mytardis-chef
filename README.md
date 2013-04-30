Overview
========
*Written by Steve Androulakis (github user steveandroulakis) on 9th August 2012, updated 30th April 2013*

This Cookbook installs the current master of MyTardis - [http://github.com/mytardis/mytardis][1]

It's been tested and confirmed to work on Ubuntu 10 (Lucid), 12 (see notes below), and CentOS 6.

It's also been tested using Vagrant and the NeCTAR Research Cloud (see [http://nectar.org.au/][2]).

Download or git clone this cookbook and use it with Chef Solo (see https://github.com/mytardis/mytardis-chef/wiki/Chef-Solo-Guide) or upload it to Hosted Chef (look on Chef's site for guides).

This installation is very minimal (no accounts, no example data) but is enough to get you started.

Health Warning
==============

If you use this recipe for building a "production" MyTardis instance (i.e. one where the data matters), then you need to be aware of a couple of things:

 1. This recipe does not set up backups of either the MyTardis database or the data store area weher data files are kept.  You need to make your own arrangements.
 1. MyTardis uses South migration for managing database schema changes, and this recipe in its current form will apply any pending South migrations without any warning.  This ''should'' work, but there is always a risk that the migration will go wrong, and that you will be left with a corrupted database.  It is prudent to ''back up your database and data'' before you attempt to deploy a new version.

 1. This recipe works by checking out and building MyTardis from a designated branch of a designated repository.  This can be risky.  For a production MyTardis instance:
  * It is prudent to use a stable branch of MyTardis rather than 'master' some other development branch.  
  * Consider creating your own MyTardis fork and using that so that you don't get surprise redeployments.  (Especially if you are tracking 'master'.)
  * It is prudent to try out redeployments in a Test or UAT instance rather than redeploying straight into production.

Configuration
=============

This doesn't really differ from other Chef cookbook installations, so I recommend you follow their Getting Started Guide [http://wiki.opscode.com/display/chef/Fast+Start+Guide][4] which will help you setup a Chef Client Workstation (to control deployments) and a Hosted Chef account (to store cookbooks and pull them down from the server).

This guide will cover two methods. Vagrant (virtual machine on your local computer) and remote instances.

Local Deployment
-------

See https://github.com/mytardis/mytardis-chef/wiki/Chef-Solo-Guide for a guide (including using Vagrant).

Remote Deployment
-------

This is a guide to deploying this on a remote server. This has been tested using the NecTAR cloud (like Amazon ec2) on Ubuntu 10, 12 and CentOS 6.

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

Run these commands from your knife client workstation (your local machine). You may need to copy your knife.rb username.pem and client-validator.pem to ~/.chef so you can run the knife command from any directory.

For CentOS 6, where <ip> is the ip address of the target server and root is the name of your superuser account. Note: depending on your remote machine, you may need to use key authentication by inserting '-i /path/to/yourkey.pem' in the account.

    knife bootstrap <ip> -x root -r 'role[mytardis]'

For Ubuntu 10 (Lucid)

    knife bootstrap <ip> -x ubuntu --sudo -r 'role[mytardis]'

For Ubuntu 12:

    knife bootstrap <ip> -x ubuntu --sudo -d ubuntu12.04-gems -r 'role[mytardis]'

That's it! You should watch knife invoke chef on the target server and watch the deployment unfold before your eyes.

Amazon EC2 Deployment
-------

Instructions for remotely deploying MyTardis on an Amazon EC2 instance.

**Prerequisites:**
*  Have a chef knife workstation set up sufficiently so you can communicate with either a Chef Server or Hosted Chef. An example knife.rb is as follows:

```
log_level                :info
log_location             STDOUT
# your chef-server or hosted chef username
node_name                'admin'
# your key downloaded from chef-server or hosted chef
client_key               '/root/.chef/admin.pem'
# your validator key name downloaded from chef-server or hosted chef
validation_client_name   'chef-validator' 
# your validator key downloaded from chef-server or hosted chef
validation_key           '/root/.chef/validation.pem'
# if using chef server then the URL
chef_server_url          'https://spetznatz.ath.cx'
# usually a subdir of your username on the knife workstation
syntax_check_cache_path  '/root/.chef/syntax_check_cache'
```
*  An Amazon EC2 account (know your access key ID and secret key)
*  SSH keys created and downloaded for logging into an EC2 instance

Install the knife ec2 plugin:

`gem install knife-ec2` (or see https://github.com/opscode/knife-ec2)

Here's a sample command that spins up an EC2 instance of [CentOS 6.2](http://thecloudmarket.com/image/ami-8035b9b0--centos-6-2-x86-64-virtastic-120619) and deploys MyTardis.

```
knife ec2 server create \ 
    -r "role[mytardis-3]" \
    -I ami-8035b9b0 --flavor m1.small \
    -x ec2-user -N mytardis \
    --aws-access-key-id "FROM_AMAZON_EC2_CONSOLE" \
    --aws-secret-access-key "FROM_AMAZON_EC2_CONSOLE" \
    --ssh-key "CREATED_IN_AMAZON" --identity-file "CREATED_IN_AMAZON.pem" \
    --region us-west-2 --json-attributes "`<solo/node.json`"
```

*  This cookbook must be uploaded to your chef server or hosted chef (see previous Remote Deployment section)
*  The roles/mytardis.json must be loaded into the server
*  The AMI used is available on the us-west2 (oregon) region. If you decide to deploy elsewhere, then find a new image.
*  The json-attributes is loaded from solo/node.json in this repository as an example. You can create your own if you wish, or edit this one
*  Make sure you've set up default security rules on the EC2 management console to allow connections to port 80, or else you'll end up with a server you can't connect to!

  [1]: http://github.com/mytardis/mytardis
  [2]: http://nectar.org.au/
  [3]: http://github.com/stevage
  [4]: http://wiki.opscode.com/display/chef/Fast+Start+Guide
  [5]: http://vagrantup.com/v1/docs/getting-started/index.html
