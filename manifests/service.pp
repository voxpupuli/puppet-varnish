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

class varnish::service (
  Optional[String]               $start                  = 'yes',
  Optional[Stdlib::Absolutepath] $vcl_reload_script      = $::varnish::params::vcl_reload_script
) inherits ::varnish::params {

  # include install
  include ::varnish::install

  # set state
  $service_state = $start ? {
    'no'    => stopped,
    default => running,
  }

  service {'varnish':
    ensure  => $service_state,
    require => Package['varnish'],
  }
  systemd::dropin_file{'varnish_service':
    unit     => 'varnish.service',
    content  => template('varnish/varnish.dropin.erb'),
    filename => 'varnish_override.conf',
    require  => Service['varnish'],
  }
}
