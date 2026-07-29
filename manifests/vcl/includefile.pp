# @summary Used by vcl.pp to create the config files with header sections
#
# TODO: Move these resources to vcl.pp??
#
# @param includedir
#   Dir that contains the includefiles
#
# @api private
define varnish::vcl::includefile (
  Optional[Stdlib::Absolutepath] $includedir = $varnish::vcl::includedir
) {
  # These concat targets are VCL content included by the main VCL, so, like
  # the main VCL file in varnish::vcl, they notify Exec['varnish-vcl-reload']
  # (a hot reload) instead of Service['varnish'] (a full restart). `before
  # => Service['varnish']` restates the ordering the notify used to provide
  # implicitly.
  concat { "${includedir}/${title}.vcl":
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Exec['varnish-vcl-reload'],
    require => File[$includedir],
    before  => Service['varnish'],
  }

  concat::fragment { "${title}-header":
    target  => "${includedir}/${title}.vcl",
    content => "# File managed by Puppet\n",
    order   => '01',
  }
}
