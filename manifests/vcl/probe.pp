# @summary Defines a VCL Probe, that can be used for healthchecks for backends
#
# Defined probes must be used
#
# @see https://varnish-cache.org/docs/trunk/reference/vcl-probe.html
#
# @param probe_name
#   The actual probe name
# @param interval
#   Paramter as defined from varnish
# @param timeout
#   Paramter as defined from varnish
# @param threshold
#   Paramter as defined from varnish
# @param window
#   Paramter as defined from varnish
# @param includedir
#   Directory where includefiles will be created
# @param url
#   Paramter as defined from varnish
# @param request
#   Paramter as defined from varnish
define varnish::vcl::probe (
  Pattern['\A[A-Za-z0-9_]+\z'] $probe_name = $title,
  String $interval  = '5s',
  String $timeout   = '5s',
  String $threshold = '3',
  String $window    = '8',
  String $includedir = $varnish::vcl::includedir,
  Optional[String] $url       = undef,
  Optional[Variant[String,Array[String]]] $request   = undef,
) {
  # parameters for probe
  $probe_params = ['interval', 'timeout', 'threshold', 'window', 'url', 'request']

  concat::fragment { "${probe_name}-probe":
    target  => "${includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order   => '02',
  }
}
