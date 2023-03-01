# @summary Mounts shmlog as tempfs
#
# @param shmlog_dir
#   directory where Varnish logs
# @param tempfs
#   mount or not shmlog as tmpfs, boolean
# @param size
#   size definition of shmlog tmpfs
#
# @example Disable config for mounting shmlog as tmpfs
#   class { 'varnish::shmlog':
#     tempfs => false,
#   }
class varnish::shmlog (
  Stdlib::Absolutepath $shmlog_dir = '/var/lib/varnish',
  Boolean              $tempfs     = true,
  String               $size       = '170M',
) {
  file { 'shmlog-dir':
    ensure  => directory,
    path    => $shmlog_dir,
    seltype => 'varnishd_var_lib_t',
  }

  # mount shared memory log dir as tmpfs
  $shmlog_share_state = $tempfs ? {
    true    => mounted,
    default => absent,
  }

  $options = $facts['os']['selinux']['enabled'] ? {
    true    => "defaults,noatime,size=${size},rootcontext=system_u:object_r:varnishd_var_lib_t:s0",
    default => "defaults,noatime,size=${size}",
  }

  mount { 'shmlog-mount':
    ensure  => $shmlog_share_state,
    name    => $shmlog_dir,
    target  => '/etc/fstab',
    fstype  => 'tmpfs',
    device  => 'tmpfs',
    options => $options,
    pass    => '0',
    dump    => '0',
    require => File['shmlog-dir'],
  }
}
