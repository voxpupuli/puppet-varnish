# == Class: varnish
# @summary
# Installs and configures Varnish.
# Tested on Ubuntu and CentOS.
#
#
# === Parameters
# @param service_ensure
#   Ensure for varnishservice
# @param reload_vcl
#   V4 paramter if Varnish will be reloaded - deprecated
#   Will be removed when support for RHEL7 is dropped
# @param nfiles
#   passed to varnish conf-file
# @param memlock
#   passed to varnish conf-file
# @param storage_type
#   which storage will be used for varnish - default malloc
# @param varnish_vcl_conf
#   path to main vcl file
# @param varnish_user
#   passed to varnish-conf
# @param varnish_jail_user
#   passed to varnish-conf
# @param varnish_group
#   passed to varnish-conf
# @param varnish_listen_address
#   Address varnish will bind to - default ''
# @param varnish_listen_port
#   port varnish wil bind to
# @param varnish_proxy_listen_address
#   address varnish binds to in proxy mode
# @param varnish_proxy_listen_port
#   port varnish binds to in proxy mode
# @param varnish_admin_listen_address
#   address varnish binds to in admin mode
# @param varnish_admin_listen_port
#   port varnish binds to in admin mode
# @param varnish_min_threads
#   minumum no of varnish worker threads
# @param varnish_max_threads
#   maximum no of varnish worker threads
# @param varnish_thread_timeout
# @param varnish_storage_size
#   defines the size of storage (depending of storage_type)
# @param varnish_secret_file
#   path to varnish secret file
# @param varnish_storage_file
#   defines the filepath of storage (depending of storage_type)
# @param varnish_ttl
#   default ttl for items
# @param varnish_enterprise
#   passed to varnish::install
# @param varnish_enterprise_vmods_extra
#   passed to varnish::install
# @param vcl_dir
#   dir where varnish vcl will be stored
# @param shmlog_dir
#   location for shmlog
# @param shmlog_tempfs
#   mounts shmlog directory as tmpfs
# @param version
#   passed to puppet type 'package', attribute 'ensure'
# @param add_repo
#   if set to false (defaults to true), the yum/apt repo is not added
# @param manage_firewall
#   passed to varnish::firewall
# @param varnish_conf_template
#   Template that will be used for varnish conf
# @param conf_file_path
#   path where varnish conf will be stored
# @param additional_parameters
#   additional parameters that will be passed to varnishd with -p
# @param default_version
#   Default major version of Varnish for that OS release
# 
# === Examples
# 
# @example installs Varnish
#   - enabled Varnish service
#   - uses default VCL '/etc/varnish/default.vcl'
#   class {'varnish': }
#
# @example same as above, plus
#   - sets Varnish to listen on port 80
#   - storage size is set to 2 GB
#   - vcl file is '/etc/varnish/my-vcl.vcl'
#   class {'varnish':
#     varnish_listen_port  => 80,
#     varnish_storage_size => '2G',
#     varnish_vcl_conf     => '/etc/varnish/my-vcl.vcl',
#   }
#
class varnish (
  Stdlib::Ensure::Service $service_ensure               = 'running',
  Boolean               $reload_vcl                   = true,
  String                $nfiles                       = '131072',
  String                $memlock                      = '100M',
  String                $storage_type                 = 'malloc',
  Stdlib::Absolutepath  $varnish_vcl_conf             = '/etc/varnish/default.vcl',
  String                $varnish_user                 = 'varnish',
  String                $varnish_jail_user            = 'vcache',
  String                $varnish_group                = 'varnish',
  Optional[String]      $varnish_listen_address       = undef,
  Stdlib::Port          $varnish_listen_port          = 6081,
  String                $varnish_proxy_listen_address       = '127.0.0.1',
  Optional[Stdlib::Port]  $varnish_proxy_listen_port          = undef,
  String                $varnish_admin_listen_address = 'localhost',
  Stdlib::Port $varnish_admin_listen_port    = 6082,
  String $varnish_min_threads          = '5',
  String $varnish_max_threads          = '500',
  String $varnish_thread_timeout       = '300',
  String $varnish_storage_size         = '1G',
  Stdlib::Absolutepath $varnish_secret_file          = '/etc/varnish/secret',
  Stdlib::Absolutepath $varnish_storage_file         = '/var/lib/varnish-storage/varnish_storage.bin',
  String $varnish_ttl                  = '120',
  Boolean $varnish_enterprise   = false,
  Boolean $varnish_enterprise_vmods_extra = false,
  Optional[Stdlib::Absolutepath] $vcl_dir                      = undef,
  Stdlib::Absolutepath $shmlog_dir                   = '/var/lib/varnish',
  Boolean $shmlog_tempfs                = true,
  String $version                      = present,
  Boolean $add_repo             = false,
  Boolean $manage_firewall      = false,
  String $varnish_conf_template        = 'varnish/varnish-conf.erb',
  Stdlib::Absolutepath $conf_file_path  = '/etc/varnish/varnish.params',
  Hash $additional_parameters        = {},
  Integer $default_version = 6,
) {
  $major_version = $version ? {
    /(\d+)\./ => "${1}",
    default => $default_version,
  }

  Class['varnish::install'] -> Class['varnish::service']
  # install Varnish
  class { 'varnish::install':
    add_repo                       => $add_repo,
    manage_firewall                => $manage_firewall,
    varnish_listen_port            => $varnish_listen_port,
    version                        => $version,
    varnish_enterprise             => $varnish_enterprise,
    varnish_enterprise_vmods_extra => $varnish_enterprise_vmods_extra,
  }

  # enable Varnish service
  include varnish::service

  # mount shared memory log dir as tempfs
  if $shmlog_tempfs {
    class { 'varnish::shmlog':
      shmlog_dir => $shmlog_dir,
      require    => Package['varnish'],
    }
  }

  # varnish config file
  file { 'varnish-conf':
    ensure  => file,
    path    => $conf_file_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($varnish_conf_template),
    require => Package['varnish'],
    notify  => Service['varnish'],
  }

  # storage dir
  $varnish_storage_dir = regsubst($varnish_storage_file, '(^/.*)(/.*$)', '\1')
  file { 'storage-dir':
    ensure  => directory,
    path    => $varnish_storage_dir,
    require => Package['varnish'],
  }
}
