# @summary Defines a Backend for VCL
#
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
  Optional[Integer] $connect_timeout       = undef,
  Optional[Integer] $first_byte_timeout    = undef,
  Optional[Integer] $between_bytes_timeout = undef,
) {
  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in backend name ${title}. Only letters, numbers and underscore are allowed.")

  concat::fragment { "${title}-backend":
    target  => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order   => '02',
  }
}
