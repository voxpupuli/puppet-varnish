require 'spec_helper'

# TODO: add more sophisticated tests, but for
# now you can't rspec concat content

describe 'varnish::vcl', type: :class do
  context 'default values' do
    let :facts do
      {
        concat_basedir: '/dne',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('varnish') }
    it {
      is_expected.to contain_file('varnish-vcl').with(
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[varnish]',
        'notify'  => 'Service[varnish]',
      )
    }
    it { is_expected.to contain_file('/etc/varnish/includes').with_ensure('directory') }
    it { is_expected.to contain_file('/etc/varnish/includes').with_purge(true) }

    # Includefiles
    it { is_expected.to contain_varnish__vcl__includefile('probes') }
    it { is_expected.to contain_varnish__vcl__includefile('backends') }
    it { is_expected.to contain_varnish__vcl__includefile('directors') }
    it { is_expected.to contain_varnish__vcl__includefile('acls') }
    it { is_expected.to contain_varnish__vcl__includefile('backendselection') }
    it { is_expected.to contain_varnish__vcl__includefile('waf') }
    it { is_expected.to contain_concat__fragment('waf').with_target('/etc/varnish/includes/waf.vcl') }

    # Contents of Includefiles
    it { is_expected.to contain_concat('/etc/varnish/includes/probes.vcl') }
    it { is_expected.to contain_concat('/etc/varnish/includes/backends.vcl') }
    it { is_expected.to contain_concat('/etc/varnish/includes/directors.vcl') }
    it { is_expected.to contain_concat('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat('/etc/varnish/includes/backendselection.vcl') }
    it { is_expected.to contain_concat('/etc/varnish/includes/waf.vcl') }

    it { is_expected.to contain_concat__fragment('probes-header').with_target('/etc/varnish/includes/probes.vcl') }
    it { is_expected.to contain_concat__fragment('backends-header').with_target('/etc/varnish/includes/backends.vcl') }
    it { is_expected.to contain_concat__fragment('directors-header').with_target('/etc/varnish/includes/directors.vcl') }
    it { is_expected.to contain_concat__fragment('acls-header').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('backendselection-header').with_target('/etc/varnish/includes/backendselection.vcl') }
    it { is_expected.to contain_concat__fragment('waf-header').with_target('/etc/varnish/includes/waf.vcl') }

    # Backends
    it { is_expected.to contain_varnish__backend('default').with_host('127.0.0.1') }
    it { is_expected.to contain_varnish__backend('default').with_port('8080') }
    it { is_expected.to contain_concat__fragment('default-backend') }

    # Default ACL
    it { is_expected.to contain_varnish__acl('blockedips').with_hosts([]) }
    it { is_expected.to contain_varnish__acl('unset_headers_debugips').with_hosts(['172.0.0.1']) }
    it { is_expected.to contain_concat__fragment('unset_headers_debugips-acl_head').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('unset_headers_debugips-acl_body').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('unset_headers_debugips-acl_tail').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_varnish__acl('purge').with_hosts([]) }
  end

  context 'manual backends' do
    let :params do
      {
        backends: {
          test: {
            host: '127.0.0.2',
            port: '8081',
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_varnish__backend('test').with_host('127.0.0.2') }
    it { is_expected.to contain_varnish__backend('test').with_port('8081') }
    it { is_expected.to contain_concat__fragment('test-backend').with_target('/etc/varnish/includes/backends.vcl') }
  end

  context 'manual probes' do
    let :params do
      {
        probes: {
          test: {
            url: '/',
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_varnish__probe('test') }
    it { is_expected.to contain_concat__fragment('test-probe') }
  end

  context 'manual directors' do
    let :params do
      {
        directors: {
          test: {
            backends: ['default'],
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_varnish__director('test') }
    it { is_expected.to contain_concat__fragment('test-director') }
  end

  context 'manual selectors' do
    let :params do
      {
        selectors: {
          test: {
            condition: 'req.url ~ "/"',
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_varnish__selector('test').with_condition('req.url ~ "/"') }
    it { is_expected.to contain_concat__fragment('test-selector').with_target('/etc/varnish/includes/backendselection.vcl') }
  end
end
