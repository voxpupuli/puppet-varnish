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
# @param max_connections
#   define varnish maximum number of connections to the backend
# @param ssl
#   varnish-plus: Set this true (1) to enable SSL/TLS for this backend.
# @param ssl_sni
#   varnish-plus: Set this to false (0) to disable the use of the Server Name Indication (SNI) extension for backend TLS connections
# @param ssl_verify_peer
#   varnish-plus: Set this to false (0) to disable verification of the peer’s certificate chain.
# @param ssl_verify_host
#   varnish-plus: Set this to true (1) to enable verification of the peer’s certificate identity
# @param host_header
#   varnish-plus: A host header to add to probes and regular backend requests if they have no such header
# @param certificate
#   varnish-plus: Specifies a client certificate to be used
define varnish::vcl::backend (
  Stdlib::Host  $host,
  Stdlib::Port  $port,
  Optional[String]  $probe                 = undef,
  Optional[Variant[String[1],Integer]] $connect_timeout       = undef,
  Optional[Variant[String[1],Integer]] $first_byte_timeout    = undef,
  Optional[Variant[String[1],Integer]] $between_bytes_timeout = undef,
  Optional[Integer] $max_connections = undef,
  Optional[Integer[0,1]] $ssl = undef,
  Optional[Integer[0,1]] $ssl_sni = undef,
  Optional[Integer[0,1]] $ssl_verify_peer = undef,
  Optional[Integer[0,1]] $ssl_verify_host = undef,
  Optional[String[1]] $host_header = undef,
  Optional[String[1]] $certificate = undef,
  Varnish::VCL::Ressource $backend_name = $title,
) {
  concat::fragment { "${title}-backend":
    target  => "${varnish::vcl::includedir}/backends.vcl",
    content => template('varnish/includes/backends.vcl.erb'),
    order   => '02',
  }
}
