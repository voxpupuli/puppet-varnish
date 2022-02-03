#selector.pp
define varnish::selector(
  String $condition,
  $director = $name,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
  $order = '03',
  Stdlib::Absolutepath $includedir = $varnish::vcl::includedir,
  String $varnish_major_version = $varnish::major_version
) {
  $template_selector = $varnish_major_version ? {
    '4'     => 'varnish/includes/backendselection4.vcl.erb',
    default => 'varnish/includes/backendselection4.vcl.erb',
  }

  concat::fragment { "${title}-selector":
    target  => "${includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => $order,
  }

}
