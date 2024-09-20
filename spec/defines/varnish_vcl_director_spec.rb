# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::director', type: :define do
  let :pre_condition do
    [
      'class { "varnish": }',
      'class { "varnish::vcl": }',
    ]
  end
  let(:title) { 'foo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end
      let(:params) { { backends: ['192.168.10.14'] } }

      context('expected behaviour') do
        it {
          is_expected.to contain_concat__fragment('foo-director').with_content(%r{new foo})
        }
      end

      context('invalid title') do
        let(:title) { '-wrong_title' }

        it 'causes a failure' do
          is_expected.to compile.and_raise_error(%r{.*})
        end
      end

      context('title != director_name') do
        let(:params) { super().merge('director_name' => 'bar') }

        it { is_expected.to contain_concat__fragment('foo-director').with_content(%r{new bar}) }
      end
    end
  end
end
