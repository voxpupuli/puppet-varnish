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
          is_expected.to contain_service('varnishncsa').with(
            'ensure' => 'running',
            'require' => 'Service[varnish]'
          )
        }

        it {
          is_expected.to contain_systemd__dropin_file('varnishncsa_service').with(
            'unit'     => 'varnishncsa.service',
            'content'  => '# THIS FILE IS MANAGED BY PUPPET
[Service]
Type=forking
KillMode=process
ExecStart=
ExecStart=/usr/bin/varnishncsa -a -w /var/log/varnish/varnishncsa.log -D -P /run/varnishncsa/varnishncsa.pid

[Unit]
Wants=network-online.target
After=network.target network-online.target
',
            'filename' => 'varnishncsa_override.conf'
          )
        }
      end

      context 'with enable false' do
        let(:params) { { enable: false } }

        it { is_expected.to contain_service('varnishncsa').with('enable' => false) }
      end

      context 'with service_ensure stopped' do
        let(:params) { { service_ensure: 'stopped' } }

        it { is_expected.to contain_service('varnishncsa').with('ensure' => 'stopped') }
      end

      context 'with all disabled' do
        let(:params) { { service_ensure: 'stopped', enable: false } }

        it { is_expected.to contain_service('varnishncsa').with('ensure' => 'stopped') }
        it { is_expected.to contain_service('varnishncsa').with('enable' => false) }
      end
    end
  end
end
