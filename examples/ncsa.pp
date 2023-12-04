#Install varnish with varnishncsa

class { 'varnish':
  add_ncsa => true,
}
