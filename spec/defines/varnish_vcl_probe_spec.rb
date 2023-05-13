# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::probe', type: :define do
  let :pre_condition do
    '
    '
  end

  let(:title) { 'foo' }
  let(:params) do
    {
      url: '/',
      includedir: '/etc/varnish/includes',
    }
  end

  context('expected behaviour') do
    it {
      is_expected.to contain_concat__fragment('foo-probe').with_target('/etc/varnish/includes/probes.vcl')
      is_expected.to contain_concat__fragment('foo-probe').with_content(%r{probe foo \{})
    }
  end

  context('invalid title') do
    let(:title) { '-wrong_title' }

    it 'causes a failure' do
      is_expected.to compile.and_raise_error(%r{.*})
    end
  end

  context('title != probe_name') do
    let(:params) { super().merge('probe_name' => 'bar') }

    it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{probe bar \{}) }
  end
end
