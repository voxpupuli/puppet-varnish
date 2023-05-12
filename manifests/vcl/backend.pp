# @summary Defines a Backend for VCL
#
# @param host
#   Host that will be defined as backend
# @param port
#   Port of the backend host
# @param backend_name
#   The actual backend name
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
  Pattern['\A[A-Za-z0-9_]+\z'] $backend_name = $title,
  Optional[String]  $probe                 = undef,
  Optional[Variant[String[1],Integer]] $connect_timeout       = undef,
  Optional[Variant[String[1],Integer]] $first_byte_timeout    = undef,
  Optional[Variant[String[1],Integer]] $between_bytes_timeout = undef,
) {
  concat::fragment { "${backend_name}-backend":
    target  => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order   => '02',
  }
}
