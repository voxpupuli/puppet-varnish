# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::selector', type: :define do
  let :pre_condition do
    [
      'class { "::varnish": }',
      'class { "::varnish::vcl": }',
    ]
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      let(:title) { 'foo' }
      let(:params) do
        {
          condition: 'req.url ~ "/"',
          includedir: '/etc/varnish/includes',
          vcl_version: '4',
        }
      end

      context('expected behaviour') do
        it {
          is_expected.to contain_concat__fragment('foo-selector').with_target('/etc/varnish/includes/backendselection.vcl')
          is_expected.to contain_concat__fragment('foo-selector').with_content(%r{\sset req.backend_hint = foo;})
        }
      end

      context('set order') do
        let(:params) do
          {
            order: '04',
            condition: 'req.url ~ "/"',
            includedir: '/etc/varnish/includes',
            vcl_version: '4',
          }
        end

        it {
          is_expected.to contain_concat__fragment('foo-selector').with_order('04')
        }
      end

      context('set rewrite') do
        let(:params) do
          {
            condition: 'req.url ~ "/"',
            includedir: '/etc/varnish/includes',
            rewrite: 'test.exaple.com',
            vcl_version: '4',
          }
        end

        it {
          is_expected.to contain_concat__fragment('foo-selector').with_content(%r{\sset req.http.x-host = test.exaple.com;})
        }
      end
    end
  end
end
