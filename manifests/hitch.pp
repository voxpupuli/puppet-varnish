# @summary Installs Hitch the SSL Offloading Proxy of Varnish Enterprise
# @see https://github.com/varnish/hitch/blob/master/hitch.conf.man.rst
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
#   Define Frontends for hitch
# @param backend
#   Define Backend
# @param pem_files
#   PEM Files that will be loaded
# @param ssl_engine
#   Set the ssl-engine
# @param tls_protos
#   allowed TLS Protos
# @param ciphers
#   allowed ciphers
# @param ciphersuites
#   allowd cipersuites for TLS1.3+
# @param workers
#   number of workers
# @param backlog
#   Listen backlog size
# @param keepalive
#   Number of seconds a TCP socket is kept alive
# @param chroot
#   Chroot directory
# @param user
#   User to run as. If Hitch is started as root, it will insist on changing to a user with lower rights after binding to sockets.
# @param group
#   If given, Hitch will change to this group after binding to listen sockets.
# @param log_level
#   Log chattiness. 0=silence, 1=errors, 2=info/debug.
#   This setting can also be changed at run-time by editing the configuration file followed by a reload (SIGHUP).
# @param syslog
#   Send messages to syslog. 
# @param syslog_facility
#   Set the syslog facility. 
# @param daemon
#   Run as daemon
# @param write_proxy
#   Which Proxy mode is used
# @param sni_nomatch_abort
#   Abort handshake when the client submits an unrecognized SNI server name.
# @param tcp_fastopen
#   Enable TCP Fast Open.
# @param alpn_protos
#   Comma separated list of protocols supported by the backend
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
