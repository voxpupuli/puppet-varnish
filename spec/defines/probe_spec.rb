require 'spec_helper'

describe 'varnish::probe', type: :define do
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
    }
  end
end
