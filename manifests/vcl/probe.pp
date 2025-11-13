# @summary Defines a VCL Probe, that can be used for healthchecks for backends
#
# Defined probes must be used
#
# @see https://varnish-cache.org/docs/trunk/reference/vcl-probe.html
#
# @param probe_name
#    Name of the probe
# @param interval
#   Paramter as defined from varnish
# @param timeout
#   Paramter as defined from varnish
# @param threshold
#   Paramter as defined from varnish
# @param window
#   Paramter as defined from varnish
# @param expected_response
#   The expected HTTP status
# @param includedir
#   Directory where includefiles will be created
# @param url
#   Paramter as defined from varnish
# @param request
#   Paramter as defined from varnish
define varnish::vcl::probe (
  Optional[Varnish::Vcl::Duration] $interval  = undef,
  Optional[Varnish::Vcl::Duration] $timeout   = undef,
  Optional[Variant[String[1],Integer[0,1024]]] $threshold = undef,
  Optional[Variant[String[1],Integer[0,1024]]] $window    = undef,
  Optional[Variant[String[1],Integer[0,1024]]] $expected_response = undef,
  String $includedir = $varnish::vcl::includedir,
  Optional[String] $url       = undef,
  Optional[Variant[String,Array[String]]] $request   = undef,
  Varnish::VCL::Ressource $probe_name = $title,
) {
  # parameters for probe
  $probe_params = ['interval', 'timeout', 'threshold', 'window', 'url', 'request', 'expected_response']

  concat::fragment { "${title}-probe":
    target  => "${includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order   => '02',
  }
}
