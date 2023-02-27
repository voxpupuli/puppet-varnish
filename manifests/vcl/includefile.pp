# define include file type
# @param includedir
#   Dir that contains the includefiles
# @api private
define varnish::vcl::includefile (
  Optional[Stdlib::Absolutepath] $includedir = $varnish::vcl::includedir
) {
  concat { "${includedir}/${title}.vcl":
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['varnish'],
    require => File[$includedir],
  }

  concat::fragment { "${title}-header":
    target  => "${includedir}/${title}.vcl",
    content => "# File managed by Puppet\n",
    order   => '01',
  }
}
