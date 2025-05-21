# @summary Installs and configures Varnish.
#
# @param service_ensure
#   Ensure for varnishservice
# @param service_enable
#   If Service should be enabled
# @param reload_vcl
#   V4 paramter if Varnish will be reloaded - deprecated
#   Will be removed when support for RHEL7 is dropped
# @param nfiles
#   passed to varnish conf-file
# @param memlock
#   passed to varnish conf-file
# @param storage_type
#   which storage will be used for varnish - default malloc
# @param transient_malloc
# Configure transient memory allocation if requried (optional)
# Example hiera config varnish::transient_malloc: '512m'
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
# @param varnish_proxy_listen_socket
#   socket varnish binds to in proxy mode
# @param varnish_proxy_listen_socket_mode
#   Filemode for socket varnish binds to in proxy mode
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
# @param mse_config
#   MSE Config, see https://docs.varnish-software.com/varnish-cache-plus/features/mse/
# @param mse_config_file
#   filepath where mse config file will be stored
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
# @param varnish_pid_file_path
#   path where varnish will store its PID file
# @param additional_parameters
#   additional parameters that will be passed to varnishd with -p
# @param default_version
#   Default major version of Varnish for that OS release
# @param add_hitch
#   Add varnish::hitch class to install hitch
# @param add_ncsa
#   Add varnish::ncsa class to install varnishncsa Service
#
# @example Installs Varnish
#   # enables Varnish service
#   # uses default VCL '/etc/varnish/default.vcl'
#   include varnish
#
# @example Installs Varnish with custom options
#   # sets Varnish to listen on port 80
#   # storage size is set to 2 GB
#   # vcl file is '/etc/varnish/my-vcl.vcl'
#   class { 'varnish':
#     varnish_listen_port  => 80,
#     varnish_storage_size => '2G',
#     varnish_vcl_conf     => '/etc/varnish/my-vcl.vcl',
#   }
#
class varnish (
  Stdlib::Ensure::Service $service_ensure               = 'running',
  Boolean               $service_enable               = true,
  Boolean               $reload_vcl                   = true,
  String                $nfiles                       = '131072',
  String                $memlock                      = '100M',
  String                $storage_type                 = 'malloc',
  String                $transient_malloc             = 'undef',
  Stdlib::Absolutepath  $varnish_vcl_conf             = '/etc/varnish/default.vcl',
  String                $varnish_user                 = 'varnish',
  Optional[String]      $varnish_jail_user            = undef,
  String                $varnish_group                = 'varnish',
  Optional[String[1]]   $varnish_listen_address       = undef,
  Stdlib::Port          $varnish_listen_port          = 6081,
  String                $varnish_proxy_listen_address       = '127.0.0.1',
  Optional[Stdlib::Port]  $varnish_proxy_listen_port          = undef,
  Optional[Stdlib::Absolutepath] $varnish_proxy_listen_socket = undef,
  Stdlib::Filemode $varnish_proxy_listen_socket_mode = '666',
  String                $varnish_admin_listen_address = 'localhost',
  Stdlib::Port $varnish_admin_listen_port    = 6082,
  String $varnish_min_threads          = '5',
  String $varnish_max_threads          = '500',
  String $varnish_thread_timeout       = '300',
  String $varnish_storage_size         = '1G',
  Stdlib::Absolutepath $varnish_secret_file          = '/etc/varnish/secret',
  Stdlib::Absolutepath $varnish_storage_file         = '/var/lib/varnish-storage/varnish_storage.bin',
  Optional[String[1]] $mse_config = undef,
  Stdlib::Absolutepath $mse_config_file = '/etc/varnish/mse.conf',
  String $varnish_ttl                  = '120',
  Boolean $varnish_enterprise   = false,
  Boolean $varnish_enterprise_vmods_extra = false,
  Optional[Stdlib::Absolutepath] $vcl_dir                      = undef,
  Stdlib::Absolutepath $shmlog_dir                   = '/var/lib/varnish',
  Boolean $shmlog_tempfs                = true,
  String[1] $version                      = present,
  Boolean $add_repo             = false,
  Boolean $manage_firewall      = false,
  String[1] $varnish_conf_template        = 'varnish/varnish-conf.erb',
  Stdlib::Absolutepath $conf_file_path  = '/etc/varnish/varnish.params',
  Optional[Stdlib::Absolutepath] $varnish_pid_file_path = undef,
  Hash $additional_parameters        = {},
  Integer $default_version = 6,
  Boolean $add_hitch = false,
  Boolean $add_ncsa = false,
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

  if($add_hitch) {
    contain varnish::hitch
  }

  #Allow to add Varnishncsa from base class
  if($add_ncsa) {
    contain varnish::ncsa
  }

  # mount shared memory log dir as tempfs
  if $shmlog_tempfs {
    class { 'varnish::shmlog':
      shmlog_dir => $shmlog_dir,
      require    => Package['varnish'],
    }
  }

  # Handle MSE Config
  if $storage_type == 'mse' and $mse_config {
    file { 'varnish-mse-conf':
      ensure  => file,
      path    => $mse_config_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => $mse_config,
      require => Package['varnish'],
      notify  => Service['varnish'],
    }
    ~> exec { 'varnish-mkfs-mse':
      command     => "mkfs.mse -c ${mse_config_file} -f",
      refreshonly => true,
      path        => [
        '/usr/local/sbin',
        '/usr/local/bin',
        '/usr/sbin',
        '/usr/bin',
        '/sbin',
        '/bin',
      ],
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
