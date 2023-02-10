require 'spec_helper'

# TODO: add more sophisticated tests, but for
# now you can't rspec concat content

describe 'varnish::vcl', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let :pre_condition do
        'include varnish'
      end

      context 'default values' do
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

        context 'functions arround' do
          let :params do
            {
              functions: {
                vcl_recv_prepend: 'vcl_recv_prepend',
                vcl_recv_append: 'vcl_recv_append',
              },
            }
          end

          it { is_expected.to compile }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_recv_prepend}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_recv_append}) }
        end

        context 'functions replace' do
          let :params do
            {
              functions: {
                vcl_init: 'vcl_init',
                vcl_recv: 'vcl_recv',
                vcl_hash: 'vcl_hash',
                vcl_pipe: 'vcl_pipe',
                vcl_hit: 'vcl_hit',
                vcl_miss: 'vcl_miss',
                vcl_pass: 'vcl_pass',
                vcl_backend_response: 'vcl_backend_response',
                vcl_deliver: 'vcl_deliver',
              },
            }
          end

          it { is_expected.to compile }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_init}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_recv}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_hash}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_pipe}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_hit}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_miss}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_pass}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_backend_response}) }
          it { is_expected.to contain_file('varnish-vcl').with_content(%r{vcl_deliver}) }
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

        context 'manual ACLS' do
          let :params do
            {
              acls: {
                test: {
                  hosts: ['127.0.0.1/32'],
                },
              },
            }
          end

          it { is_expected.to compile }
          it { is_expected.to contain_varnish__acl('test').with_hosts(['127.0.0.1/32']) }
          it { is_expected.to contain_concat__fragment('test-acl_head').with_target('/etc/varnish/includes/acls.vcl') }
          it { is_expected.to contain_concat__fragment('test-acl_tail').with_target('/etc/varnish/includes/acls.vcl') }
          it { is_expected.to contain_concat__fragment('test-acl_body').with_target('/etc/varnish/includes/acls.vcl') }
        end

        context 'manual purgeips' do
          let :params do
            {
              purgeips: ['127.0.0.12/32'],
            }
          end

          it { is_expected.to compile }
          it { is_expected.to contain_varnish__acl('purge').with_hosts(['127.0.0.12/32']) }
          it { is_expected.to contain_concat__fragment('purge-acl_head').with_target('/etc/varnish/includes/acls.vcl') }
          it { is_expected.to contain_concat__fragment('purge-acl_tail').with_target('/etc/varnish/includes/acls.vcl') }
          it { is_expected.to contain_concat__fragment('purge-acl_body').with_target('/etc/varnish/includes/acls.vcl') }
        end
      end
    end
  end
end
