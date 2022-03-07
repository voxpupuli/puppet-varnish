require 'spec_helper'

describe 'varnish::acl', type: :define do
  let :pre_condition do
    'class { "::varnish::vcl": }'
  end

  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/dne' } }

  context('expected behaviour') do
    let(:params) { { hosts: ['192.168.10.14'] } }

    it { is_expected.to contain_concat__fragment('foo-acl_body').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('foo-acl_body').with_content(%r{^\s+\"192.168.10.14\";\s+$}) }
    it { is_expected.to contain_concat__fragment('foo-acl_head').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('foo-acl_head').with_content(%r{^acl foo \{$}) }
    it { is_expected.to contain_concat__fragment('foo-acl_tail').with_target('/etc/varnish/includes/acls.vcl') }
    it { is_expected.to contain_concat__fragment('foo-acl_tail').with_content(%r{^\}\s+$}) }
  end

  context('invalid acl title') do
    let(:title) { '-wrong_title' }
    let(:params) { { hosts: ['192.168.10.14'] } }

    it 'causes a failure' do
      is_expected.to compile.and_raise_error(%r{Invalid characters in ACL name -wrong_title. Only letters, numbers and underscore are allowed.})
    end
  end
end
