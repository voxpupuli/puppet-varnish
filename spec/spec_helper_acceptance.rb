# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'epel-release') if fact_on(host, 'os.family') == 'RedHat' && fact_on(host, 'os.release.major') == '7'
  install_package(host, 'curl')
  install_package(host, 'nginx')
  on(host, 'systemctl start nginx')
end
