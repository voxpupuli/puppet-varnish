#director.pp
define varnish::director (
  String $type = 'round-robin',
  Array $backends = [],
  String $vcl_version = $varnish::vcl::vcl_version
) {
  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in director name ${title}. Only letters, numbers and underscore are allowed.")

  case $vcl_version {
    '4': {
      $template_director = 'varnish/includes/directors4.vcl.erb'
      $director_object = $type ? {
        'round-robin' => 'round_robin',
        'client' => 'hash',
        default => $type
      }
    }
    '3': {
      $template_director = 'varnish/includes/directors.vcl.erb'
    }
    default: {
      $template_director = 'varnish/includes/directors4.vcl.erb'
      $director_object = $type ? {
        'round-robin' => 'round_robin',
        'client' => 'hash',
        default => $type
      }
    }
  }

  #if versioncmp($::varnish::params::version, '4') >= 0 {
  #  $template_director = 'varnish/includes/directors4.vcl.erb'
  #  $director_object = $type ? {
  #    'round-robin' => 'round_robin',
  #    'client' => 'hash',
  #    default => $type
  #  }
  #} else {
  #  $template_director = 'varnish/includes/directors.vcl.erb'
  #}

  concat::fragment { "${title}-director":
    target  => "${varnish::vcl::includedir}/directors.vcl",
    content => template($template_director),
    order   => '02',
  }
}
