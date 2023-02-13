#selector.pp
# @summary
#   Adds a selector to handle multiple backends
#   Depending to the condition, requests will be sent to the correct backend
# 
# @param condition
#   Condtion under that varnish will redirect to the defined backend
#   Must be valid VCL if conditon
# @param director
#   Director that will be used for the requests
# @param rewrite
#   Rewrite Header X-Host to this value
# @param newurl
#   rewrite URL to this URL
# @param movedto
#   Instead of backend, sent redirect to this Baseurl
# @param order
#   Order value for selector statements
# @param includedir
#   Directory for include files
# @param vcl_version
#   Version of VCL Language
define varnish::vcl::selector (
  String $condition,
  String $director = $name,
  Optional[String] $rewrite = undef,
  Optional[String] $newurl = undef,
  Optional[String] $movedto = undef,
  Variant[String, Integer] $order = '03',
  Stdlib::Absolutepath $includedir = $varnish::vcl::includedir,
  Varnish::Vclversion $vcl_version = $varnish::vcl::vcl_version
) {
  $template_selector = $vcl_version ? {
    '4'     => 'varnish/includes/backendselection4.vcl.erb',
    default => 'varnish/includes/backendselection4.vcl.erb',
  }

  concat::fragment { "${title}-selector":
    target  => "${includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => $order,
  }
}
