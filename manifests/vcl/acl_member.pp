# @summary Allows to add ACL Memebers with exported ressources. These are collected by vcl class

# @param varnish_fqdn
#   Tag name of the varnish host that is collected
# @param acl
#   Name of the ACL that should be created
# @param host
#   Host ip that will be inserted
define varnish::vcl::acl_member (
  String $varnish_fqdn,
  String $acl,
  Stdlib::IP::Address $host,
) {
  unless defined(Concat::Fragment["${acl}-acl_head"]) {
    concat::fragment { "${acl}-acl_head":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => "acl ${acl} {\n",
      order   => "02-${acl}-1-0",
    } -> concat::fragment { "${acl}-acl_tail":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => "}\n",
      order   => "02-${acl}-3-0",
    }
  }
  $hosts = [$host]
  concat::fragment { "${acl}-acl_${host}":
    target  => "${varnish::vcl::includedir}/acls.vcl",
    content => template('varnish/includes/acls_body.vcl.erb'),
    order   => "02-${acl}-2-${host}",
  }
}
