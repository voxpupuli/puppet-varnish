# @summary Defines a backend director in varnish vcl
#
# @param director_name
#   The actual director name
# @param type
#   Type of varnish backend director
# @param backends
#   Array of backends for the director, backends need to be defined as varnish::vcl:backend
# @param vcl_version
#   Version of vcl Language
define varnish::vcl::director (
  Pattern['\A[A-Za-z0-9_]+\z'] $director_name = $title,
  String $type = 'round-robin',
  Array[String] $backends = [],
  Varnish::Vclversion $vcl_version = $varnish::vcl::vcl_version
) {
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

  concat::fragment { "${director_name}-director":
    target  => "${varnish::vcl::includedir}/directors.vcl",
    content => template($template_director),
    order   => '02',
  }
}
