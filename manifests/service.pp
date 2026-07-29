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
# @param enable
#   If Service should be enabled
# @param vcl_reload_script
#   Path to reload script. Unused by this module; kept only so that existing
#   callers passing it do not fail catalog compilation. Use
#   $vcl_reload_command instead.
# @param vcl_reload_command
#   Command used to hot-load a new VCL into the running varnishd without a
#   full service restart. Must exit non-zero if the new VCL fails to compile
#   or load. Triggered by changes to VCL content (see varnish::vcl and
#   varnish::vcl::includefile), as opposed to Service['varnish'], which is
#   still notified by changes to daemon-level settings (storage, listen
#   address, thread pools, the systemd unit, etc.) that cannot be applied to
#   a running process.
#
# @api private
class varnish::service (
  Stdlib::Ensure::Service $ensure              = $varnish::service_ensure,
  Boolean                 $enable              = $varnish::service_enable,
  Stdlib::Absolutepath    $vcl_reload_script   = '/usr/share/varnish/reload-vcl',
  String[1]               $vcl_reload_command  = 'systemctl reload varnish',
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
    enable  => $enable,
  }

  # VCL content (the main VCL file and its include files) can be hot-loaded
  # into a running varnishd without dropping the cache or in-flight
  # connections. This exec gives those resources somewhere to notify instead
  # of Service['varnish'], which would otherwise restart the daemon on every
  # VCL-only change.
  exec { 'varnish-vcl-reload':
    command     => $vcl_reload_command,
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    require     => Service['varnish'],
    # Only relevant when the daemon is actually running: with `ensure =>
    # stopped` there is nothing to hot-load into, and on a fresh start
    # Service['varnish'] has already picked up the current VCL. This
    # deliberately does not swallow a failing reload -- if varnishd is up
    # and the new VCL is invalid, the command runs, exits non-zero, and the
    # exec resource fails, leaving the previous (still valid) VCL active.
    onlyif      => 'systemctl is-active --quiet varnish',
  }
}
