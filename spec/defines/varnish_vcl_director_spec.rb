require 'spec_helper'

describe 'varnish::vcl::director', type: :define do
  let :pre_condition do
    [
      'class { "::varnish": }',
      'class { "::varnish::vcl": }',
    ]
  end
  let(:title) { 'foo' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context('expected behaviour') do
        let(:params) { { backends: ['192.168.10.14'] } }

        it {
          is_expected.to contain_concat__fragment('foo-director').with_content(%r{new foo})
        }
      end
    end
  end
end
