# ncsa.pp
class varnish::ncsa (
  Boolean $enable = true,
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

  $service_ensure = $enable ? {
    true => 'running',
    default => 'stopped',
  }

  service { 'varnishncsa':
    ensure    => $service_ensure,
    enable    => $enable,
    require   => Service['varnish'],
    subscribe => File['/etc/default/varnishncsa'],
  }
}
