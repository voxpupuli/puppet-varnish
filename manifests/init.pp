# == Class: varnish
#
# Installs and configures Varnish.
# Tested on Ubuntu and CentOS.
#
#
# === Parameters
# All parameters are just a low case replica of actual parameters passed to
# the Varnish conf file, $class_parameter -> VARNISH_PARAMETER, i.e.
# $memlock             -> MEMLOCK
# $varnish_vcl_conf    -> VARNISH_VCL_CONF
# $varnish_listen_port -> VARNISH_LISTEN_PORT
#
# Exceptions are:
# shmlog_dir    - location for shmlog
# shmlog_tempfs - mounts shmlog directory as tmpfs
#                 default value: true
# version       - passed to puppet type 'package', attribute 'ensure'
# add_repo      - if set to false (defaults to true), the yum/apt repo is not added
#
# === Default values
# Set to Varnish default values
# With an exception to
# - $storage_type, which is set to 'malloc' in this module
# - $varnish_storage_file, path to which is changed to /var/lib/varnish-storage
#                          this is done to avoid clash with $shmlog_dir
#
# === Examples
#
# - installs Varnish
# - enabled Varnish service
# - uses default VCL '/etc/varnish/default.vcl'
# class {'varnish': }
#
# same as above, plus
# - sets Varnish to listen on port 80
# - storage size is set to 2 GB
# - vcl file is '/etc/varnish/my-vcl.vcl'
# class {'varnish':
#   varnish_listen_port  => 80,
#   varnish_storage_size => '2G',
#   varnish_vcl_conf     => '/etc/varnish/my-vcl.vcl',
# }
#

class varnish (
  String                $start                        = 'yes',
  Boolean               $reload_vcl                   = true,
  String                $nfiles                       = '131072',
  String                $memlock                      = '82000',
  String                $storage_type                 = 'malloc',
  Stdlib::Absolutepath  $varnish_vcl_conf             = '/etc/varnish/default.vcl',
  String                $varnish_user                 = 'varnish',
  String                $varnish_jail_user            = 'vcache',
  String                $varnish_group                = 'varnish',
  String                $varnish_listen_address       = '',
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
  Boolean $add_repo             = $::varnish::params::add_repo,
  Boolean $manage_firewall      = false,
  String $varnish_conf_template        = 'varnish/varnish-conf.erb',
  Hash $additional_parameters        = {},
) inherits ::varnish::params {

  $major_version = $version ? {
    /(\d+)\./ => "${1}",
    default => $::varnish::params::version
  }

  # install Varnish
  class {'varnish::install':
    add_repo                       => $add_repo,
    manage_firewall                => $manage_firewall,
    varnish_listen_port            => $varnish_listen_port,
    version                        => $version,
    varnish_enterprise             => $varnish_enterprise,
    varnish_enterprise_vmods_extra => $varnish_enterprise_vmods_extra,
  }

  # enable Varnish service
  -> class {'varnish::service':
    start => $start,
  }

  # mount shared memory log dir as tempfs
  if $shmlog_tempfs {
    class { 'varnish::shmlog':
      shmlog_dir => $shmlog_dir,
      require    => Package['varnish'],
    }
  }

  # varnish config file
  file { 'varnish-conf':
    ensure  => present,
    path    => $varnish::params::conf_file_path,
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
