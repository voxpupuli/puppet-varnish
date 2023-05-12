# @summary Defines an ACL Type of Varnish. Defined ACL's must be used in VCL
#
# @param hosts
#    Array of defined Hosts
# @param acl_name
#    The actual ACL name
define varnish::vcl::acl (
  Array[Stdlib::IP::Address] $hosts,
  Pattern['\A[A-Za-z0-9_]+\z'] $acl_name = $title,
) {
  # Varnish does not allow empty ACLs
  if size($hosts) > 0 {
    unless defined(Concat::Fragment["${acl_name}-acl_head"]) {
      concat::fragment { "${acl_name}-acl_head":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "acl ${acl_name} {\n",
        order   => "02-${acl_name}-1-0",
      } -> concat::fragment { "${acl_name}-acl_tail":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "}\n",
        order   => "02-${acl_name}-3-0",
      }
    }
    concat::fragment { "${acl_name}-acl_body":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => template('varnish/includes/acls_body.vcl.erb'),
      order   => "02-${acl_name}-2-0",
    }
  }
}
