#
# Cookbook:: 3_Middleman
# Recipe:: default
#
# Copyright:: 2018, Evan Haxton, All Rights Reserved.

# apt-get update
apt_update 'update'

# apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
apt_package %w( build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3 ) do
  action :upgrade
end

# make working directory
directory 'ruby' do
  mode '0755'
  path '/home/vagrant/ruby'
  action :create
  not_if { ::File.exist?('/usr/local/bin/ruby') }
end

# download tarball
# wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
remote_file '/home/vagrant/ruby/ruby-2.1.3.tar.gz' do
  source 'http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz'
  not_if { ::File.exist?('/home/vagrant/ruby/ruby-2.1.3.tar.gz') }
end

# extract tarball to /home/vagrant/ruby
tar_extract '/home/vagrant/ruby/ruby-2.1.3.tar.gz' do
  action :extract_local
  target_dir '/home/vagrant/ruby'
  notifies :run, 'execute[build_ruby]', :immediately
  creates '/usr/bin/ruby'
end

# Build ruby
# cd ruby-2.1.3 & ./configure & make install
execute 'build_ruby' do
  command 'sudo ./configure && sudo make install'
  cwd '/home/vagrant/ruby/ruby-2.1.3'
  not_if { ::File.exist?('/usr/local/bin/ruby') }
end

# rm -rf ~/ruby
directory '/home/vagrant/ruby' do
  recursive true
  action :delete
  only_if { ::File.exist?('/usr/local/bin/ruby') }
end

# cp /usr/local/bin/ruby /usr/bin/ruby
file '/usr/bin/ruby' do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open('/usr/local/bin/ruby').read
  action :create
  not_if { ::File.exist?('/usr/bin/ruby') }
end

# cp /usr/local/bin/gem /usr/bin/gem
file '/usr/bin/gem' do
  owner 'root'
  group 'root'
  mode 0755
  content ::File.open('/usr/local/bin/gem').read
  action :create
  not_if { ::File.exist?('/usr/bin/gem') }
end

# apt-get install apache2
apt_package 'apache2'

# Configure apache2

# a2enmod proxy_http
execute 'proxy_http' do
  command 'sudo a2enmod proxy_http'
  not_if { ::File.exist?('/etc/apache2/mods-enabled/proxy_http.load') }
end

# a2enmod rewrite
execute 'proxy_http' do
  command 'sudo a2enmod rewrite'
  not_if { ::File.exist?('/etc/apache2/mods-enabled/rewrite.load') }
end

# cp blog.conf /etc/apache2/sites-enabled/blog.conf
template '/etc/apache2/sites-enabled/blog.conf' do
  source 'blog.conf.erb'
end

# rm /etc/apache2/sites-enabled/000-default.conf
file '/etc/apache2/sites-enabled/000-default.conf' do
  action :delete
  manage_symlink_source true
  only_if { File.exist? '/etc/apache2/sites-enabled/000-default.conf' }
end

# Restart apache
service 'apache2' do
  action :reload
end

# Install Git
# apt-get install git
apt_package 'git'

# Install Middleman blog repository
# git clone https://github.com/learnchef/middleman-blog.git
git '/home/vagrant/middleman-blog' do
  repository 'https://github.com/learnchef/middleman-blog.git'
  revision 'master'
  action :checkout
end

# Install Bundler
# gem install bundler
gem_package 'bundler' do
  action :install
end

# Install new user to install gem files
user 'apache' do
  manage_home true
  comment 'Apache user'
  home '/home/apache'
  shell '/bin/bash'
  password 'apache'
end

# Install project dependencies

# bundle install
execute 'bundle_install' do
  command 'bundle install'
  cwd '/home/vagrant/middleman-blog'
  user 'apache'
end
