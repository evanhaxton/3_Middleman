#
# Cookbook:: 3_Middleman
# Recipe:: default
#
# Copyright:: 2018, Evan Haxton, All Rights Reserved.

# apt-get update
apt_update 'update'

# apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
apt_package %w( build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3) do
  action :install
end

# make working directory
directory 'ruby' do
  mode '0755'
  path '/home/vagrant/ruby'
  action :create
end

# download tarball
# wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
remote_file '/home/vagrant/ruby/ruby-2.1.3.tar.gz' do
  source 'http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz'
  not_if { ::File.exist?('/usr/local/bin/ruby') }
end

# extract tarball to /home/vagrant/ruby
tar_extract '/home/vagrant/ruby/ruby-2.1.3.tar.gz' do
  action :extract_local
  target_dir '/home/vagrant/ruby'
  notifies :run, 'execute[build_ruby]', :immediately
  creates '/usr/bin/ruby'
  not_if { ::File.exist?('/usr/local/bin/ruby') }
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
  only_if { ::File.exist?('/home/vagrant/ruby') }
end

# cp /usr/local/bin/ruby /usr/bin/ruby
file '/usr/bin/ruby' do
  owner 'root'
  group 'root'
  mode 0755
  lazy { content ::File.open('/usr/local/bin/ruby').read }
  action :create
  only_if { ::File.exist?('/usr/local/bin/ruby') }
end

# cp /usr/local/bin/gem /usr/bin/gem
file '/usr/bin/gem' do
  owner 'root'
  group 'root'
  mode 0755
  lazy { content ::File.open('/usr/local/bin/gem').read }
  action :create
  only_if { ::File.exist?('/usr/local/bin/gem') }
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
  only_if { ::File.exist?('/etc/apache2/sites-enabled/000-default.conf') }
end

# Restart apache
service 'apache2' do
  action :reload
end

# Install Git
# apt-get install git
apt_package 'git'

# Create apache user
user 'apache' do
  manage_home true
  comment 'Apache User'
  home '/home/apache'
  shell '/bin/bash'
  password 'apache'
end

sudo 'apache' do
  user 'apache'
  nopasswd true
end

# Install project dependencies

# Make /home/apache writable
directory '/home/apache' do
  mode '0757'
  action :create
end

# make working directory for bundle install
directory '/home/apache/.bundle/cache/compact_index' do
  mode '1777'
  recursive true
  owner 'apache'
  action :create
  not_if { ::File.exist?('/home/apache/.bundle/cache/compact_index') }
end

# make working directory for bundle install
directory '/tmp' do
  mode '1777'
  recursive true
  action :create
end

# Install Middleman blog repository
# git clone https://github.com/learnchef/middleman-blog.git
git '/home/apache/middleman-blog' do
  repository 'https://github.com/learnchef/middleman-blog.git'
  revision 'master'
  user 'apache'
  action :checkout
  not_if { ::File.exist?('/home/apache/middleman-blog') }
end

# Install Bundler
# gem install bundler
gem_package 'bundler' do
  version '1.16.1'
  action :install
  not_if { ::File.exist?('/usr/local/lib/ruby/gems/2.1.0/gems/bundler-1.16.1') }
end

# Create apache user
user 'apache' do
  manage_home true
  comment 'Apache User'
  home '/home/apache'
  shell '/bin/bash'
  password 'apache'
end

sudo 'apache' do
  user 'apache'
  nopasswd true
end

# bundle install
execute 'bundle_install' do
  command 'bundle install'
  environment 'tmpdir' => '/tmp'
  cwd '/home/apache/middleman-blog'
  user 'apache'
  not_if { ::File.exist?('/usr/local/lib/ruby/gems/2.1.0/gems/middleman-3.1.0') }
end

# establish configuration file
template '/etc/blog.yml' do
  source 'blog.yml.erb'
  variables project_install_directory: '/var/www/middleman'
  not_if { ::File.exist?('/etc/blog.yml') }
end

# make working directory
directory 'middleman' do
  mode '0755'
  path '/var/www/middleman'
  action :create
end

template '/etc/init.d/thin' do
  source 'thin.erb'
  mode '0755'
  variables home_directory: '/var/www/middleman'
  not_if { ::File.exist?('/etc/init.d/thin') }
end

# thin install /usr/sbin/update-rc.d -f thin defaults
execute 'thin install' do
  command '/usr/sbin/update-rc.d -f thin defaults'
end

# restart service
service 'thin' do
  action :restart
end
