require 'spec_helper'

describe 'varnish::selector', type: :define do
  let :pre_condition do
    '
    '
  end

  let(:title) { 'foo' }
  let(:params) do
    {
      condition: 'req.url ~ "/"',
      includedir: '/etc/varnish/includes',
      varnish_major_version: '6',
    }
  end

  context('expected behaviour') do
    it {
      is_expected.to contain_concat__fragment('foo-selector').with_target('/etc/varnish/includes/backendselection.vcl')
    }
  end
  context('set order') do
    let(:params) do
      {
        order: '04',
        condition: 'req.url ~ "/"',
        includedir: '/etc/varnish/includes',
        varnish_major_version: '6',
      }
    end

    it {
      is_expected.to contain_concat__fragment('foo-selector').with_order('04')
    }
  end
end
