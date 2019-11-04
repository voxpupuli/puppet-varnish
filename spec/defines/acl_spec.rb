require 'spec_helper'

describe 'varnish::acl', type: :define do
  let :pre_condition do
    'class { "::varnish::vcl": }'
  end

  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/dne' } }

  context('expected behaviour') do
    let(:params) { { hosts: ['192.168.10.14'] } }

    it { is_expected.to contain_file('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('foo-acl') }
  end

  context('invalid acl title') do
    let(:title) { '-wrong_title' }

    it 'causes a failure' do
      expect { is_expected.to raise_error(Puppet::Error, 'Invalid characters in ACL name _wrong-title. Only letters, numbers and underscore are allowed.') }
    end
  end
end
