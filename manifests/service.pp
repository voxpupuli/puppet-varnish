# == Class: varnish::service
#
# Enables/Disables Varnish service
#
# === Parameters
#
# start - 'yes' or 'no' to start varnishd at boot
#          default value: 'yes'
#
# === Examples
#
# make sure Varnish is running
# class {'varnish::service':}
#
# disable Varnish
# class {'varnish::service':
#   start => 'no',
# }
# 
# @api private

class varnish::service (
  Optional[String]               $start                  = $varnish::start,
  Optional[Stdlib::Absolutepath] $vcl_reload_script      = '/usr/share/varnish/reload-vcl'
) {
  # include install
  include varnish::install

  # set state
  $service_state = $start ? {
    'no'    => stopped,
    default => running,
  }

  systemd::dropin_file { 'varnish_service':
    unit     => 'varnish.service',
    content  => epp('varnish/varnish.dropin.epp'),
    filename => 'varnish_override.conf',
    # require  => Service['varnish'],
  }
  ~> service { 'varnish':
    ensure  => $service_state,
    require => Package['varnish'],
  }
}
