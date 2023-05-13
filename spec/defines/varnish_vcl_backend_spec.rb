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
          connect_timeout: 5,
          first_byte_timeout: '10m',
          between_bytes_timeout: '5s',
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

      context('invalid title') do
        let(:title) { '-wrong_title' }

        it 'causes a failure' do
          is_expected.to compile.and_raise_error(%r{.*})
        end
      end

      context('title != backend_name') do
        let(:params) { super().merge('backend_name' => 'bar') }

        it { is_expected.to contain_concat__fragment('foo-backend').with_content(%r{backend bar \{}) }
      end
    end
  end
end
