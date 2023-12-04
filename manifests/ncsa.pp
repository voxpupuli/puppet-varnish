# @summary Allows setup of varnishncsa
#
# @param enable
#   enable service
# @param service_ensure
#   ensure serice
# @param varnishncsa_daemon_opts
#   Options handed to varnishncsa
class varnish::ncsa (
  Boolean $enable = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String $varnishncsa_daemon_opts = '-a -w /var/log/varnish/varnishncsa.log -D -P /run/varnishncsa/varnishncsa.pid',
) {
  systemd::dropin_file { 'varnishncsa_service':
    unit     => 'varnishncsa.service',
    content  => epp('varnish/varnishncsa.dropin.epp', { 'daemon_opts' => $varnishncsa_daemon_opts }),
    filename => 'varnishncsa_override.conf',
  }
  ~> service { 'varnishncsa':
    ensure  => $service_ensure,
    enable  => $enable,
    require => Service['varnish'],
  }
}
