# Class varnish::repo
# @summary
#   This class installs aditional repos for varnish
# @param version
#   Version of varnish for repo
# @param enable
#   If repo will be managed
class varnish::repo (
  Optional[String] $version  = undef,
  Boolean $enable   = false,
) {
  $repo_base_url = 'https://packagecloud.io/varnishcache'

  $repo_distro = $facts['os']['name'] ? {
    'RedHat'    => 'redhat',
    'LinuxMint' => 'ubuntu',
    'centos'    => 'redhat',
    'amazon'    => 'redhat',
    'debian'    => 'ubuntu',
    default     => downcase($facts['os']['name']),
  }

  $repo_version = $version ? {
    /^4\.0/ => '4.0',
    /^4\.1/ => '4.1',
    default => '60lts',
  }

  if $enable {
    case $facts['os']['family'] {
      'redhat': {
        yumrepo { 'varnish':
          descr    => 'varnish',
          enabled  => '1',
          gpgcheck => '1',
          priority => '1',
          gpgkey   => "${repo_base_url}/varnish${repo_version}/gpgkey",
          baseurl  => "${repo_base_url}/varnish${repo_version}/el/${facts['os']['release']['major']}/${facts['os']['architecture']}",
        }
      }
      'debian': {
        apt::source { 'varnish':
          location => "${repo_base_url}/varnish${repo_version}/${repo_distro}/",
          repos    => "varnish-${repo_version}",
          key      => {
            id     => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD',
            source => "${repo_base_url}/varnish${repo_version}/gpgkey",
          },
        }
      }
      default: {
      }
    }
  }
}
