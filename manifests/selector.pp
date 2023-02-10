#selector.pp
define varnish::selector (
  String $condition,
  String $director = $name,
  Optional[String] $rewrite = undef,
  Optional[String] $newurl = undef,
  Optional[String] $movedto = undef,
  Variant[String, Integer] $order = '03',
  Stdlib::Absolutepath $includedir = $varnish::vcl::includedir,
  String $vcl_version = $varnish::vcl::vcl_version
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
