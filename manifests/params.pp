# == Class: varnish::params
#

class varnish::params {
  # set Varnish conf location based on OS
  case $::facts['os']['name'] {
    'RedHat': {
      $default_version = $::facts['os']['release']['major'] ? {
        '7' => '4',
        '8' => '6',
      }
      $add_repo = false
      $vcl_reload_script = '/usr/sbin/varnish_reload_vcl'
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $systemd_conf_path = '/usr/lib/systemd/system/varnish.service'
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        fail("Class['varnish::params']: Unsupported os version: ${::facts['os']['name']} - ${::operatingsystemmajrelease}")
      }
    }
    'Debian': {
      $default_version = $::facts['os']['release']['major'] ? {
        '8' => '4',
        '9' => '5',
        '10' => '6',
      }
      if versioncmp($::facts['os']['release']['major'], '8') >= 0 {
          $add_repo = false
          $systemd_conf_path = '/lib/systemd/system/varnish.service'
          $conf_file_path = '/etc/varnish/varnish.params'
          $vcl_reload_script = '/usr/share/varnish/reload-vcl'

      }
      else{
          fail("Class['varnish::params']: Unsupported os version: ${::facts['os']['name']} - ${::facts['os']['release']['major']}")
      }
    }
    'Ubuntu': {
      $default_version = $::facts['os']['release']['major'] ? {
        '16.04' => '4',
        '18.04' => '5',
        '20.04' => '6',
      }
      if versioncmp($::facts['os']['release']['major'], '16.04') >= 0 {
          $add_repo = false
          $systemd_conf_path = '/lib/systemd/system/varnish.service'
          $conf_file_path = '/etc/varnish/varnish.params'
          $vcl_reload_script = '/usr/share/varnish/reload-vcl'

      }
      else{
          fail("Class['varnish::params']: Unsupported os version: ${::facts['os']['name']} - ${::facts['os']['release']['major']}")
      }
    }
    default: {
      fail("Class['varnish::params']: Unsupported os: ${::facts['os']['name']}")
    }
  }
  $version = $default_version
}
