# @summary Manages the Varnish VCL configuration
#
# To change name/location of vcl file, use $varnish_vcl_conf in the main varnish class
#
# NOTE: though you can pass config for backends, directors, acls, probes and selectors
#       as parameters to this class, it is recommended to use existing definitions instead:
#       varnish::backend
#       varnish::director
#       varnish::probe
#       varnish::acl
#       varnish::selector
#       See README for details on how to use those
#
# @param functions
#   Hash of additional function definitions
# @param probes
#   Hash of probes, defined as varnish::vcl::probe
# @param backends
#   Hash of backends, defined as varnish::vcl::backend
# @param directors
#   Hash of directors, defined as varnish::vcl::director
# @param selectors
#   Hash of selectors, defined as varnish::vcl::selector
# @param acls
#   Hash of acls, defined as varnish::vcl::acl
# @param blockedips
#   Array of IP's that will be blocked with default VCL
# @param blockedbots
#   Array of UserAgent Bots that will be blocked
# @param enable_waf
#   controls VCL WAF component, can be true or false
# @param pipe_uploads
#   If the request is a post/put upload (chunked or multipart),
#   pipe the request to the backend.
# @param wafexceptions
#   Exclude those rules
# @param purgeips
#   source ips which are allowed to send purge requests
# @param includedir
#   Dir for includefiles
# @param manage_includes
#   If Includes (and Subtypes like directors, probes,.. ) should be created
# @param cookiekeeps
#   Cookies that should be kept for backend
# @param defaultgrace
#   Default Grace time for Iptems
# @param min_cache_time
#   Default Cache time
# @param static_cache_time
#   Cache Time for static Elements like images,..
# @param gziptypes
#   Content Types that will be gziped
# @param template
#   Overwrite Template for VCL
# @param logrealip
#   Create std.log entry with Real IP of client
# @param honor_backend_ttl
#   if Backend TTL will be honored
# @param cond_requests
#   if condtional requests are allowed
# @param x_forwarded_proto
#   If Header x-forwared-proto should be added to hash
# @param https_redirect
#   deprecated
# @param drop_stat_cookies
#   depretaced
# @param cond_unset_cookies
#   If condtion to unset all coockies
# @param unset_headers
#   Unset the named http headers
# @param unset_headers_debugips
#   Do not unset the named headers for the following IP's
# @param vcl_version
#   Which version von VCL should be used
# @param import_vmods
#   List of vmods that should be imported
#
# @note
#   VCL applies following restictions:
#   - if you define an acl it must be used
#   - if you define a probe it must be used
#   - if you define a backend it must be used
#   - if you define a director it must be used
#   You cannot define 2 or more backends/directors and not to have selectors
#   Not following above rules will result in VCL compilation failure
class varnish::vcl (
  Hash $functions         = {},
  Hash $probes            = {},
  Hash $backends          = { 'default' => { host => '127.0.0.1', port => 8080 } },
  Hash $directors         = {},
  Hash $selectors         = {},
  Hash $acls              = {},
  Array $blockedips        = [],
  Array $blockedbots       = [],
  Boolean $enable_waf        = false,
  Boolean $pipe_uploads      = false,
  Array[String] $wafexceptions     = ['57' , '56' , '34'],
  Array[Stdlib::IP::Address] $purgeips          = [],
  Stdlib::Absolutepath $includedir        = '/etc/varnish/includes',
  Boolean $manage_includes   = true,
  Array[String] $cookiekeeps       = ['__ac', '_ZopeId', 'captchasessionid', 'statusmessages', '__cp', 'MoodleSession'],
  Optional[String] $defaultgrace      = undef,
  String $min_cache_time    = '60s',
  String $static_cache_time = '5m',
  Array[String] $gziptypes         = ['text/', 'application/xml', 'application/rss', 'application/xhtml', 'application/javascript', 'application/x-javascript'],
  Optional[String] $template          = undef,
  Boolean $logrealip         = false,
  Boolean $honor_backend_ttl = false,
  Boolean $cond_requests     = false,
  Boolean $x_forwarded_proto = false,
  Boolean $https_redirect    = false,
  Boolean $drop_stat_cookies = true,
  Optional[String] $cond_unset_cookies = undef,
  Array[String] $unset_headers     = ['Via','X-Powered-By','X-Varnish','Server','Age','X-Cache'],
  Array[Stdlib::IP::Address] $unset_headers_debugips = ['172.0.0.1'],
  Varnish::Vclversion $vcl_version     = '4',
  Optional[Array] $import_vmods = undef,
) {
  include varnish

  # select template to use
  if $template {
    $template_vcl = $template
  }
  else {
    $template_vcl = $vcl_version ? {
      '4'     => 'varnish/varnish4-vcl.erb',
      '3'     => 'varnish/varnish-vcl.erb',
      default => 'varnish/varnish4-vcl.erb',
    }
  }

  # vcl file
  file { 'varnish-vcl':
    ensure  => file,
    path    => $varnish::varnish_vcl_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($template_vcl),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  if $template == undef or $manage_includes {
    file { $includedir:
      ensure  => directory,
      purge   => true,
      recurse => true,
      require => Package['varnish'],
    }
    $includefiles = ['probes', 'backends', 'directors', 'acls', 'backendselection', 'waf']

    varnish::vcl::includefile { $includefiles: }

    # web application firewall
    concat::fragment { 'waf':
      target  => "${varnish::vcl::includedir}/waf.vcl",
      content => template('varnish/includes/waf.vcl.erb'),
      order   => '02',
    }

    #Create resources

    #Backends
    create_resources(varnish::vcl::backend,$backends)

    #Probes
    create_resources(varnish::vcl::probe,$probes)

    #Directors
    create_resources(varnish::vcl::director,$directors)

    #Selectors
    create_resources(varnish::vcl::selector,$selectors)

    #ACLs
    $default_acls = {
      blockedips => { hosts => $blockedips },
      unset_headers_debugips => { hosts => $unset_headers_debugips },
      purge => { hosts => $purgeips },
    }
    $all_acls = $default_acls + $acls
    create_resources(varnish::vcl::acl,$all_acls)
    Varnish::Vcl::Acl_member <| varnish_fqdn == $facts['networking']['fqdn'] |>
  }
}
