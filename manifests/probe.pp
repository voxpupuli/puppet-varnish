#probe.pp
define varnish::probe (
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
