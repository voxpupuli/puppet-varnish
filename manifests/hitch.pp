# @summary Installs Hitch the SSL Offloading Proxy of Varnish Enterprise
#
# @param package_name
#   Define used package name
# @param package_ensure
#   Ensure package
# @param service_ensure
#   Ensure Service status
# @param service_name
#   Service name for hitch (must match installed)
# @param config_path
#   Path for hitch config
# @param config_template
#   Used EPP Config template
# @param frontends
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param backend
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param pem_files
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param ssl_engine
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param tls_protos
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param ciphers
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param ciphersuites
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param workers
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param backlog
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param keepalive
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param chroot
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param user
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param group
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param log_level
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param syslog
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param syslog_facility
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param daemon
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param write_proxy
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param sni_nomatch_abort
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param tcp_fastopen
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param alpn_protos
#   see Parameter in https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
# @param additional_parameters
#   Add parameters additional as needed
#
# @example
#   include varnish::hitch
class varnish::hitch (
  Array[Stdlib::Absolutepath,1] $pem_files,
  String[1] $package_name = 'varnish-plus-addon-ssl',
  String[1] $package_ensure = 'present',
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name = 'hitch',
  Stdlib::Absolutepath $config_path = '/etc/hitch/hitch.conf',
  String[1] $config_template = 'varnish/hitch.conf.epp',
  Array[Struct[{ host => String[1],port => Stdlib::Port }],1] $frontends = [{ 'host'=> '*', 'port'=> 443, }],
  String[1] $backend = '[127.0.0.1]:8443',
  Optional[String[1]] $ssl_engine = undef,
  String[1] $tls_protos = 'TLSv1.2 TLSv1.3',
  String[1] $ciphers = 'EECDH+AESGCM:EDH+AESGCM',
  String[1] $ciphersuites = 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256',
  Variant[Enum['auto'],Integer[1,1024]] $workers = 'auto',
  Integer[1] $backlog = 200,
  Integer[1] $keepalive = 3600,
  Optional[Stdlib::Absolutepath] $chroot = undef,
  String[1] $user = 'hitch',
  String[1] $group = 'hitch',
  Integer[0,2] $log_level = 1,
  Boolean $syslog = true,
  Stdlib::Syslogfacility $syslog_facility = 'daemon',
  Boolean $daemon = true,
  Enum['ip','v1','v2','proxy'] $write_proxy = 'v2',
  Boolean $sni_nomatch_abort = false,
  Boolean $tcp_fastopen = false,
  String[1] $alpn_protos = 'h2,http/1.1',
  Hash[String[1],Variant[String[1],Integer[1]]] $additional_parameters = {},
) {
  package { 'hitch':
    ensure => $package_ensure,
    name   => $package_name,
  }
  service { 'hitch':
    ensure  => $service_ensure,
    name    => $service_name,
    require => Package['hitch'],
  }
  file { 'hitch-conf':
    ensure  => file,
    path    => $config_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp($config_template),
    require => Package['hitch'],
    notify  => Service['hitch'],
  }
}
