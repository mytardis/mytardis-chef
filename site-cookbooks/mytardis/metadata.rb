maintainer       "Steve Androulakis"
maintainer_email "steve.androulakis@monash.edu"
license          "All rights reserved"
description      "Installs/Configures mytardis"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.3"

depends "build-essential"
depends "git"
depends "apt"
depends "iptables"
depends "postgresql"
