# @summary Manages the Varnish service
#
# @example Make sure Varnish is running
#   include 'varnish::service'
# 
# @example Disable Varnish service
#  class { 'varnish::service':
#    ensure => stopped,
#  }
#
# @param ensure 
#   Ensure service status
# @param vcl_reload_script
#   Path to reload script
#
# @api private
class varnish::service (
  Stdlib::Ensure::Service $ensure            = $varnish::service_ensure,
  Stdlib::Absolutepath    $vcl_reload_script = '/usr/share/varnish/reload-vcl'
) {
  # include install
  include varnish::install

  systemd::dropin_file { 'varnish_service':
    unit     => 'varnish.service',
    content  => epp('varnish/varnish.dropin.epp'),
    filename => 'varnish_override.conf',
  }
  ~> service { 'varnish':
    ensure  => $ensure,
    require => Package['varnish'],
  }
}
