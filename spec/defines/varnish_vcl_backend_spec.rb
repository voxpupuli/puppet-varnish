# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::backend', type: :define do
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
          host: 'www.example.com',
          port: 80,
          probe: 'foo',
          connect_timeout: '5s',
          first_byte_timeout: '10m',
          between_bytes_timeout: 5,
        }
      end

      context('expected behaviour') do
        it {
          is_expected.to contain_concat__fragment('foo-backend').with_target('/etc/varnish/includes/backends.vcl')
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{backend foo \{})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.host = "www.example.com";})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.port = "80";})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.probe = foo;})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.connect_timeout = 5s;})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.first_byte_timeout = 10m;})
          is_expected.to contain_concat__fragment('foo-backend').with_content(%r{\s+.between_bytes_timeout = 5s;})
        }
      end
    end
  end
end
