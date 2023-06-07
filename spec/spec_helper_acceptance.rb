# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_package(host, 'curl')
  install_package(host, 'nginx')
end
