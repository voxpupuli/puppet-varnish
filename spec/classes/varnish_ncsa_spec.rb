# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::ncsa', type: :class do
  let :pre_condition do
    'include varnish'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'default values' do
        it { is_expected.to compile }

        it {
          is_expected.to contain_file('/etc/default/varnishncsa').with(
            'ensure' => 'file',
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644',
            'notify' => 'Service[varnishncsa]'
          )
        }

        it { is_expected.to contain_file('/etc/default/varnishncsa').with_content(%r{VARNISHNCSA_ENABLED=1}) }
        it { is_expected.to contain_file('/etc/default/varnishncsa').without_content(%r{DAEMON_OPTS}) }

        it {
          is_expected.to contain_service('varnishncsa').with(
            'ensure'    => 'running',
            'require'   => 'Service[varnish]',
            'subscribe' => 'File[/etc/default/varnishncsa]'
          )
        }
      end

      context 'with enable false' do
        let(:params) { { enable: false } }

        it { is_expected.to contain_file('/etc/default/varnishncsa').with_content(%r{# VARNISHNCSA_ENABLED=1}) }
        it { is_expected.to contain_service('varnishncsa').with('enable' => false) }
      end

      context 'with service_ensure stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_file('/etc/default/varnishncsa').with_content(%r{VARNISHNCSA_ENABLED=1}) }
        it { is_expected.to contain_service('varnishncsa').with('ensure' => 'stopped') }
      end

      context 'with all disabled' do
        let(:params) { { service_ensure: 'stopped', enable: false } }

        it { is_expected.to contain_file('/etc/default/varnishncsa').with_content(%r{# VARNISHNCSA_ENABLED=1}) }
        it { is_expected.to contain_service('varnishncsa').with('ensure' => 'stopped') }
        it { is_expected.to contain_service('varnishncsa').with('enable' => false) }
      end
    end
  end
end
