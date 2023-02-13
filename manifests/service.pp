# varnish::service
# @summary
#   Enables/Disables Varnish service
#
# @example make sure Varnish is running
#   class {'varnish::service':}
# 
# @example disable Varnish
#  class {'varnish::service':
#    start => 'no',
#  }
#
# @param ensure 
#   Ensure service status
#   default value: 'running'
# 
# @param vcl_reload_script
#   Path to reload script
# @api private
class varnish::service (
  Stdlib::Ensure::Service $ensure                  = $varnish::service_ensure,
  Stdlib::Absolutepath $vcl_reload_script      = '/usr/share/varnish/reload-vcl'
) {
  # include install
  include varnish::install

  systemd::dropin_file { 'varnish_service':
    unit     => 'varnish.service',
    content  => epp('varnish/varnish.dropin.epp'),
    filename => 'varnish_override.conf',
    # require  => Service['varnish'],
  }
  ~> service { 'varnish':
    ensure  => $ensure,
    require => Package['varnish'],
  }
}
