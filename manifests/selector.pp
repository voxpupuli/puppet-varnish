#selector.pp
define varnish::selector(
  $condition,
  $director = $name,
  $rewrite = undef,
  $newurl = undef,
  $movedto = undef,
  $order = '03',
) {
  $template_selector = $::varnish::major_version ? {
    '4'     => 'varnish/includes/backendselection4.vcl.erb',
    '3'     => 'varnish/includes/backendselection.vcl.erb',
    default => 'varnish/includes/backendselection4.vcl.erb',
  }

  concat::fragment { "${title}-selector":
    target  => "${varnish::vcl::includedir}/backendselection.vcl",
    content => template($template_selector),
    order   => $order,
  }

}
