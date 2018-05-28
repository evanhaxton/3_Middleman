#
# Cookbook:: 3_Middleman
# Recipe:: default
#
# Copyright:: 2018, Evan Haxton, All Rights Reserved.

# apt-get update
apt_update 'update'

# apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
package %w( build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3 ) do
  action :install
end
