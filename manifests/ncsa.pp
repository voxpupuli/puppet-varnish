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
  Optional[String] $varnishncsa_daemon_opts = undef,
) {
  file { '/etc/default/varnishncsa':
    ensure  => 'file',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('varnish/varnishncsa-default.erb'),
    notify  => Service['varnishncsa'],
  }

  service { 'varnishncsa':
    ensure    => $service_ensure,
    enable    => $enable,
    require   => Service['varnish'],
    subscribe => File['/etc/default/varnishncsa'],
  }
}
