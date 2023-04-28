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
  Optional[Variant[String[1],Integer]] $connect_timeout       = undef,
  Optional[Variant[String[1],Integer]] $first_byte_timeout    = undef,
  Optional[Variant[String[1],Integer]] $between_bytes_timeout = undef,
) {
  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in backend name ${title}. Only letters, numbers and underscore are allowed.")

  if ($connect_timeout != undef) and ($connect_timeout =~ /^[0-9]+$/) {
    $_connect_timeout = "${connect_timeout}s"
  } else {
    $_connect_timeout = $connect_timeout
  }
  if ($first_byte_timeout != undef) and ($first_byte_timeout =~ /^[0-9]+$/) {
    $_first_byte_timeout = "${first_byte_timeout}s"
  } else {
    $_first_byte_timeout = $first_byte_timeout
  }
  if ($between_bytes_timeout != undef) and ($between_bytes_timeout =~ /^[0-9]+$/) {
    $_between_bytes_timeout = "${between_bytes_timeout}s"
  } else {
    $_between_bytes_timeout = $between_bytes_timeout
  }

  concat::fragment { "${title}-backend":
    target  => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order   => '02',
  }
}
