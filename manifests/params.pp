# == Class: varnish::params
#

class varnish::params {

  # set Varnish conf location based on OS
  case $::facts['os']['name'] {
    'RedHat': {
      $default_version = '3'
      $add_repo = true
      $vcl_reload_script = '/usr/sbin/varnish_reload_vcl'
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $systemd_conf_path = '/usr/lib/systemd/system/varnish.service'
        $systemd = true
        $conf_file_path = '/etc/varnish/varnish.params'
      } else {
        $systemd = false
        $conf_file_path = '/etc/sysconfig/varnish'
        $systemd_conf_path = undef
      }
    }
    'Debian': {
      $vcl_reload_script = '/usr/share/varnish/reload-vcl'
      $add_repo = true
      $systemd = false
      $systemd_conf_path = undef
      $conf_file_path = '/etc/default/varnish'
      $default_version = '3'
    }
    'Ubuntu': {
      $vcl_reload_script = '/usr/share/varnish/reload-vcl'
      case $::facts['os']['release']['major'] {
        default: {
          $add_repo = true
          $systemd = false
          $systemd_conf_path = undef
          $conf_file_path = '/etc/default/varnish'
          $default_version = '3'
        }
        '15.10': {
          #don't add repo as in default repo
          $add_repo = false
          $systemd_conf_path = '/lib/systemd/system/varnish.service'
          $systemd = true
          $conf_file_path = '/etc/varnish/varnish.params'
          $default_version ='4'
        }
        '16.04': {
          #don't add repo as in default repo
          $add_repo = false
          $systemd_conf_path = '/lib/systemd/system/varnish.service'
          $systemd = true
          $conf_file_path = '/etc/varnish/varnish.params'
          $default_version ='4'
        }
        '18.04': {
          $add_repo = false
          $systemd_conf_path = '/lib/systemd/system/varnish.service'
          $systemd = true
          $conf_file_path = '/etc/varnish/varnish.params'
          $default_version ='5'
        }
      }
    }
    default: {
      fail("Class['apache::params']: Unsupported osfamily: ${::osfamily}")
    }
  }
  $real_version = $::varnish::version ? {
    /^(3|4|5).*/ => $::varnish::version,
    default => $default_version,
  }
  $version = $real_version ? {
    /3\..*/ => '3',
    /4\..*/ => '4',
    /5\..*/ => '5',
    /6\..*/ => '6',
    default => 4,
  }
}
