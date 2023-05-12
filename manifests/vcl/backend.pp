# @summary Defines a Backend for VCL
#
# @param backend_name
#    Name of the Backend
# @param host
#   Host that will be defined as backend
# @param port
#   Port of the backend host
# @param probe
#   Name of probe that will be used for healthcheck
# @param connect_timeout
#   define varnish connect connect_timeout
# @param first_byte_timeout
#   define varnish first_byte_timeout
# @param between_bytes_timeout
#   define varnish between_bytes_timeout
define varnish::vcl::backend (
  Stdlib::Host  $host,
  Stdlib::Port  $port,
  Optional[String]  $probe                 = undef,
  Optional[Variant[String[1],Integer]] $connect_timeout       = undef,
  Optional[Variant[String[1],Integer]] $first_byte_timeout    = undef,
  Optional[Variant[String[1],Integer]] $between_bytes_timeout = undef,
  Varnish::VCL::Ressource $backend_name = $title,
) {
  concat::fragment { "${title}-backend":
    target  => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order   => '02',
  }
}
