# @summary Installs and manages Varnish Controller Agent
#
# @param base_url
#   see https://docs.varnish-software.com/varnish-controller/installation/agents/#base-url
# @param nats_server
#   Server for NATS Connection
# @param nats_server_port
#   Port for Nats Connection
# @param nats_server_user
#   User for Nats Connection
# @param nats_server_password
#   Password for Nats Connection
# @param agent_name
#   see https://docs.varnish-software.com/varnish-controller/installation/agents/#setting-the-agent-name
# @param invalidation_host
#   see https://docs.varnish-software.com/varnish-controller/installation/agents/#varnish-interaction
# @param package_name
#   Name of the Package used for installation
# @param package_ensure
#   Ensure of the Package
# @param service_ensure
#   Ensure of Agent Service
# @example
#   include varnish::controller::agent
class varnish::controller::agent (
  Stdlib::HTTPUrl $base_url,
  Stdlib::Host $nats_server,
  Stdlib::Port $nats_server_port = 4222,
  Optional[String] $nats_server_user = undef,
  Optional[Variant[Sensitive[String],String]] $nats_server_password = undef,
  Varnish::Controller::Agent_name $agent_name = $facts['networking']['hostname'],
  String[1] $invalidation_host = '127.0.0.1:80',
  String[1] $package_name = 'varnish-controller-agent',
  String[1] $package_ensure = 'present',
  Stdlib::Ensure::Service $service_ensure = 'running',
) {
  package { 'varnish-controller-agent':
    ensure => $package_ensure,
    name   => $package_name,
  }
  systemd::dropin_file { 'varnish-controller-agent':
    unit     => 'varnish-controller-agent.service',
    content  => epp('varnish/varnish-controller-agent.dropin.epp'),
    filename => 'varnish-controller-agent.conf',
  }
  ~> service { 'varnish-controller-agent':
    ensure  => $service_ensure,
    require => Package['varnish-controller-agent'],
  }
}
