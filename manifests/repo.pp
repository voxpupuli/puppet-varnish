# Class varnish::repo
#
# This class installs aditional repos for varnish
#
class varnish::repo (
  $version  = undef,
  $base_url = '',
  Boolean $enable   = false,
  ) inherits ::varnish::params {

  $repo_base_url = 'https://packagecloud.io/varnishcache'

  $repo_distro = $::operatingsystem ? {
    'RedHat'    => 'redhat',
    'LinuxMint' => 'ubuntu',
    'centos'    => 'redhat',
    'amazon'    => 'redhat',
    'debian'    => 'ubuntu',
    default     => downcase($::operatingsystem),
  }

  $repo_version = $version ? {
    /^4\.0/ => '4.0',
    /^4\.1/ => '4.1',
    default => '60lts',
  }

  $repo_arch = $::architecture

  $osver_array = split($::operatingsystemrelease, '[.]')
  if downcase($::operatingsystem) == 'amazon' {
    $osver = $osver_array[0] ? {
      '2'     => '5',
      '3'     => '6',
      default => undef,
    }
  }
  else {
    $osver = $osver_array[0]
  }
  if $enable {
    case $::osfamily {
      redhat: {
        yumrepo { 'varnish':
          descr    => 'varnish',
          enabled  => '1',
          gpgcheck => '1',
          priority => '1',
          gpgkey   => "${repo_base_url}/varnish${repo_version}/gpgkey",
          baseurl  => "${repo_base_url}/varnish${repo_version}/el/${osver}/${repo_arch}",
        }
      }
      debian: {
        apt::source { 'varnish':
          location => "${repo_base_url}/varnish${repo_version}/${repo_distro}/",
          repos    => "varnish-${repo_version}",
          key      => {
            id     => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD',
            source => "${repo_base_url}/varnish${repo_version}/gpgkey",
          }
        }
      }
      default: {
      }
    }
  }
}
