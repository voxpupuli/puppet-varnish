# @summary Defines a VCL Probe, that can be used for healthchecks for backends
#
# Defined probes must be used
#
# @see https://varnish-cache.org/docs/trunk/reference/vcl-probe.html
#
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
  String $interval  = '5s',
  String $timeout   = '5s',
  String $threshold = '3',
  String $window    = '8',
  String $includedir = $varnish::vcl::includedir,
  Optional[String] $url       = undef,
  Optional[Variant[String,Array[String]]] $request   = undef,
) {
  validate_re($title,'^[A-Za-z0-9_]*$', "Invalid characters in probe name ${title}. Only letters, numbers and underscore are allowed.")

  # parameters for probe
  $probe_params = ['interval', 'timeout', 'threshold', 'window', 'url', 'request']

  concat::fragment { "${title}-probe":
    target  => "${includedir}/probes.vcl",
    content => template('varnish/includes/probes.vcl.erb'),
    order   => '02',
  }
}
