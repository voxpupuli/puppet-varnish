require 'spec_helper'

describe 'varnish::acl', type: :define do
  let :pre_condition do
    'class { "::varnish::vcl": }'
  end

  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/dne' } }

  context('expected behaviour') do
    let(:params) { { hosts: ['192.168.10.14'] } }

    xit { is_expected.to contain_file('/etc/varnish/includes/acls.vcl') }
    xit { is_expected.to contain_concat__fragment('foo-acl') }
  end

  context('invalid acl title') do
    let(:title) { '-wrong_title' }
    let(:params) { { hosts: ['192.168.10.14'] } }

    it 'causes a failure' do
      is_expected.to compile.and_raise_error(/Invalid characters in ACL name -wrong_title. Only letters, numbers and underscore are allowed./)
    end
  end
end
