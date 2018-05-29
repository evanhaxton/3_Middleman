# Validate that ruby has been created
describe file('/usr/local/bin/ruby') do
  it { should exist }
end

# Validate that gem has been created
describe file('/usr/local/bin/gem') do
  it { should exist }
end

# Validate that rudy working directory has been created
describe file('/home/vagrant/ruby') do
  it { should_not exist }
end

# Validate that ruby has been installed
describe file('/usr/bin/ruby') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

# Validate that gem has been installed
describe file('/usr/bin/gem') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

# Validate that apache2 has been installed
describe file('/etc/apache2/apache2.conf') do
  it { should exist }
end

# Validate that apache2 configuration file proxy_load has been installed
describe file('/etc/apache2/mods-enabled/proxy_http.load') do
  it { should exist }
end

# Validate that apache2 configuration file rewrite has been installed
describe file('/etc/apache2/mods-enabled/rewrite.load') do
  it { should exist }
end

# Validate that apache2 configuration file rewrite has been installed
describe file('/etc/apache2/sites-enabled/blog.conf') do
  it { should exist }
end
