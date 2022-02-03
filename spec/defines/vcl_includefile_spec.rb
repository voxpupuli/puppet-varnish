require 'spec_helper'

describe 'varnish::vcl::includefile', type: :define do
  let :pre_condition do
    'file { "/etc/varnish/includes":
      ensure  => directory,
      purge   => true,
      recurse => true,
    }
    service {"varnish":
      ensure => present
    }
    '
  end

  let(:title) { 'foo' }
  let(:params) { { includedir: '/etc/varnish/includes' } }

  context('expected behaviour') do
    it {
      is_expected.to contain_concat('/etc/varnish/includes/foo.vcl')
      is_expected.to contain_concat__fragment('foo-header')
    }
  end
end
