#Type for Duration in VCL definitions
type Varnish::Vcl::Duration = Variant[Pattern[/^[0-9]+(\.[0-9]*)?[smhdwy]?$/], Integer[0], Float[0]]
