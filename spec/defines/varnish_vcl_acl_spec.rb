# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::acl', type: :define do
  let :pre_condition do
    [
      'class { "varnish": }',
      'class { "varnish::vcl": }',
    ]
  end

  let(:title) { 'foo' }
  let(:facts) { { concat_basedir: '/dne' } }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      let(:params) { { hosts: ['192.168.10.14'] } }

      context('expected behaviour') do
        it { is_expected.to contain_concat__fragment('foo-acl_body').with_target('/etc/varnish/includes/acls.vcl') }
        it { is_expected.to contain_concat__fragment('foo-acl_body').with_content(%r{^\s+"192.168.10.14";\s+$}) }
        it { is_expected.to contain_concat__fragment('foo-acl_head').with_target('/etc/varnish/includes/acls.vcl') }
        it { is_expected.to contain_concat__fragment('foo-acl_head').with_content(%r{^acl foo \{$}) }
        it { is_expected.to contain_concat__fragment('foo-acl_tail').with_target('/etc/varnish/includes/acls.vcl') }
        it { is_expected.to contain_concat__fragment('foo-acl_tail').with_content(%r{^\}\s+$}) }
      end

      context('invalid acl title') do
        let(:title) { '-wrong_title' }

        it 'causes a failure' do
          is_expected.to compile.and_raise_error(%r{.*})
        end
      end

      context('title != acl_name') do
        let(:params) { super().merge('acl_name' => 'bar') }

        it { is_expected.to contain_concat__fragment('foo-acl_head').with_content(%r{^acl bar \{$}) }
      end
    end
  end
end
