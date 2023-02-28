##Table of Contents
1. [Overview](#overview)
2. [Install Varnish](#install-varnish)
3. [Class varnish](#class-varnish)
4. [Class varnish::vcl](#class-varnish-vcl)
    * [varnish::vcl::selector](varnish-selector)
    * [Configure VCL with class varnish::vcl](#configure-vcl-with-class-varnish-vcl)
7. [Tests](#tests)
8. [Contributing](#contributing)
9. [Contributors](#contributors)


[![Build Status](https://github.com/voxpupuli/puppet-varnish/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-varnish/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-varnish/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-varnish/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/varnish.svg)](https://forge.puppetlabs.com/puppet/varnish)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/varnish.svg)](https://forge.puppetlabs.com/puppet/varnish)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/varnish.svg)](https://forge.puppetlabs.com/puppet/varnish)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/varnish.svg)](https://forge.puppetlabs.com/puppet/varnish)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-varnish)

## Overview

   This Puppet module installs and configures Varnish.
   It also allows to manage Varnish VCL.
   Tested on Ubuntu, CentOS, RHEL and Oracle Linux.

   The Module is based on https://github.com/maxchk/puppet-varnish
   Since than to release 3.0.0
  - Added support for new OS
  - Dropped support outdated OS
  - Moved VCL Subclasses (acl, acl_member, backend, director, probe, selector)
  - Added support for varnish 6
  - Added support for varnish-plus / Varnish Enterprise

  Detailed Reference to all classparameters can be found in (https://github.com/voxpupuli/puppet-varnish/blob/master/REFERENCE.md)

### Important information
Version 2.0.0 drops support for old OS Versions (pre systemd)
Also drops support for pre Varnish 4

## Install Varnish

   installs Varnish
   allocates for cache 1GB (malloc)
   starts it on port 80:

    class {'varnish':
      varnish_listen_port => 80,
      varnish_storage_size => '1G',
    }

## Class varnish

   Class `varnish`
   Installs Varnish.
   Provides access to all configuration parameters.
   Controls Varnish service.
   By default mounts shared memory log directory as tmpfs.

   All parameters are low case replica of actual parameters passed to
   the Varnish conf file, `$class_parameter -> VARNISH_PARAMETER`, i.e.

    $memlock             -> MEMLOCK
    $varnish_vcl_conf    -> VARNISH_VCL_CONF
    $varnish_listen_port -> VARNISH_LISTEN_PORT

   Exceptions are:
   `shmlog_dir`    - location for shmlog
   `shmlog_tempfs` - mounts shmlog directory as tmpfs, (default value: true)
   `version`       - passes to puppet type 'package', attribute 'ensure', (default value: present)

   At minimum you may want to change a value for default port:
   `varnish_listen_port => '80'`

For more details on parameters, check class varnish.

## Class varnish vcl

   Class `varnish::vcl` manages Varnish VCL configuration.

   Varnish VCL applies following restictions:
   if you define an acl it must be used
   if you define a probe it must be used
   if you define a backend it must be used
   if you define a director it must be used

   Gives access to Varnish acl, probe, backend, director, etc. definitions
   (see below)

### varnish selector

   Definition `varnish::vcl::selector` allows to configure Varnish selector.

   While `acl`, `probe`, `backend` and `director` are self-explanatory
   WTF is `selector`?

   You cannot define 2 or more backends/directors and not to use them.
   This will result in VCL compilation failure.

   Parameter `selectors` gives access to req.backend inside `vcl_recv`.
   Code:

    ```puppet
    varnish::vcl::selector { 'cluster1': condition => 'req.url ~ "^/cluster1"' }
    varnish::vcl::selector { 'cluster2': condition => 'true' } # will act as backend set by else statement
    ```

   Will result in following VCL configuration to be generated:
    ```VCL
    if (req.url ~ "^/cluster1") {
      set req.backend = cluster1;
    }
    if (true) {
      set req.backend = cluster2;
    }
    ```

   For more examples see `tests/vcl_backends_probes_directors.pp`

## Usaging class varnish::vcl

   Configure probes, backends, directors and selectors
    ```puppet
    class { 'varnish::vcl': }
    ```

    # configure probes
    ```puppet
    varnish::probe { 'health_check1': url => '/health_check_url1' }
    varnish::probe { 'health_check2':
      window    => '8',
      timeout   => '5s',
      threshold => '3',
      interval  => '5s',
      request   => [ "GET /healthCheck2 HTTP/1.1", "Host: www.example1.com", "Connection: close" ]
    }
    ```

    # configure backends
    ```puppet
    varnish::vcl::backend { 'srv1': host => '172.16.0.1', port => '80', probe => 'health_check1' }
    varnish::vcl::backend { 'srv2': host => '172.16.0.2', port => '80', probe => 'health_check1' }
    varnish::vcl::backend { 'srv3': host => '172.16.0.3', port => '80', probe => 'health_check2' }
    varnish::vcl::backend { 'srv4': host => '172.16.0.4', port => '80', probe => 'health_check2' }
    varnish::vcl::backend { 'srv5': host => '172.16.0.5', port => '80', probe => 'health_check2' }
    varnish::vcl::backend { 'srv6': host => '172.16.0.6', port => '80', probe => 'health_check2' }
    ```

    # configure directors
    ```puppet
    varnish::vcl::director { 'cluster1': backends => [ 'srv1', 'srv2' ] }
    varnish::vcl::director { 'cluster2': backends => [ 'srv3', 'srv4', 'srv5', 'srv6' ] }
    ```

    # configure selectors
    ```puppet
    varnish::vcl::selector { 'cluster1': condition => 'req.url ~ "^/cluster1"' }
    varnish::vcl::selector { 'cluster2': condition => 'true' } # will act as backend set by else statement
    ```

   If modification to Varnish VCL goes further than configuring `probes`, `backends` and `directors`
   parameter `template` can be used to point `varnish::vcl` class at a different template.

   NOTE: If you copy existing template and modify it you will still
   be able to use `probes`, `backends`, `directors` and `selectors`.

## Redefine functions in class varnish::vcl

   With the module comes the basic Varnish vcl configuration file. If needed one can replace default
   functions in the configuration file with own ones and/or define custom functions.
   Override or custom functions specified in the array passed to `varnish::vcl` class as parameter `functions`.
   The best way to do it is to use hiera. For example:
   ```yaml
   varnish::vcl::functions:
     vcl_hash: |
       hash_data(req.url);
       if (req.http.host) {
         hash_data(req.http.host);
       } else {
         hash_data(server.ip);
       }
       return (hash);
     pipe_if_local: |
       if (client.ip ~ localnetwork) {
         return (pipe);
       }
   ```
   There are two special cases for functions `vcl_init` and `vcl_recv`.
   For Varnish version 4 in function `vcl_init` include directive for directors is always present.
   For function `vcl_recv` beside the possibility to override standard function one can also add
   peace of code to the begining or to the end of the function with special names `vcl_recv_prepend` and `vcl_recv_append`
   For instance:
   ```yaml
   varnish::vcl::functions:
     pipe_if_local: |
       if (client.ip ~ localnetwork) {
         return (pipe);
       }
     vcl_recv_prepend: |
       call pipe_if_local;
   ```

## Tests
   For more examples check module tests directory.
   NOTE: make sure you don't run tests on Production server.

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/voxpupuli/puppet-varnish/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/puppetlabs/puppet-lint) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).


## Contributors
- Max Horlanchuk <max.horlanchuk@gmail.com>
- Fabio Rauber <fabiorauber@gmail.com>
- Samuel Leathers <sam@appliedtrust.com>
- Lienhart Woitok <lienhart.woitok@netlogix.de>
- Adrian Webb <adrian.webb@coraltech.net>
- Frode Egeland <egeland@gmail.com>
- Matt Ward <matt.ward@envato.com>
- Noel Sharpe <noels@radnetwork.co.uk>
- Rich Kang <rich@saekang.co.uk>
- browarrek <browarrek@gmail.com>
- Stanislav Voroniy <stas@voroniy.com>
- Hannes Schaller <hannes.schaller@apa.at>
- Lukas Plattner <lukas.plattner@apa.at>
