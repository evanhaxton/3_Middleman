name '3_Middleman'
maintainer 'Evan Haxton'
maintainer_email 'ehaxton@gmail.com'
license 'apachev2'
description 'Installs/Configures Middleman ruby application'
long_description 'Installs/Configures Middleman ruby application'
version '0.4.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/3_Middleman/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/3_Middleman'

depends 'apt', '~> 7.0.0'
depends 'tar', '~> 2.1.1'
depends 'sudo', '~> 5.4.0'
