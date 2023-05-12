# @summary Defines an ACL Type of Varnish. Defined ACL's must be used in VCL
# 
# @param acl_name
#    Name of ACL
# @param hosts
#    Array of defined Hosts
define varnish::vcl::acl (
  Array[Stdlib::IP::Address] $hosts,
  Varnish::VCL::Ressource $acl_name = $title,
) {
  # Varnish does not allow empty ACLs
  if size($hosts) > 0 {
    unless defined(Concat::Fragment["${title}-acl_head"]) {
      concat::fragment { "${title}-acl_head":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "acl ${acl_name} {\n",
        order   => "02-${title}-1-0",
      } -> concat::fragment { "${title}-acl_tail":
        target  => "${varnish::vcl::includedir}/acls.vcl",
        content => "}\n",
        order   => "02-${title}-3-0",
      }
    }
    concat::fragment { "${title}-acl_body":
      target  => "${varnish::vcl::includedir}/acls.vcl",
      content => template('varnish/includes/acls_body.vcl.erb'),
      order   => "02-${title}-2-0",
    }
  }
}
