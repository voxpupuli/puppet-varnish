# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::controller::agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let :params do
        {
          base_url: 'http://varnish.example.com/',
          nats_server: '127.0.0.1',
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_package('varnish-controller-agent').with(
          'ensure' => 'present',
          'name'   => 'varnish-controller-agent'
        )
      }

      it {
        is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_unit('varnish-controller-agent.service')
        is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_filename('varnish-controller-agent.conf')
        is_expected.to contain_service('varnish-controller-agent').with_ensure('running')
        is_expected.to contain_service('varnish-controller-agent').with(
          'ensure'  => 'running',
          'require' => 'Package[varnish-controller-agent]'
        )
      }

      it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_AGENT_NAME=foo"}) }
      it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_NATS_SERVER=127.0.0.1:4222"}) }
      it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_BASE_URL=http://varnish.example.com/"}) }
      it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_VARNISH_INVALIDATION_HOST=127.0.0.1:80"}) }

      context 'with Package version' do
        let(:params) do
          super().merge('package_ensure' => '1.0.1')
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish-controller-agent').with(
            'ensure' => '1.0.1',
            'name'   => 'varnish-controller-agent'
          )
        }
      end

      context 'with Package Name' do
        let(:params) do
          super().merge('package_name' => 'vca')
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish-controller-agent').with(
            'ensure' => 'present',
            'name'   => 'vca'
          )
        }
      end

      context 'with Service disabled' do
        let(:params) do
          super().merge('service_ensure' => 'stopped')
        end

        it { is_expected.to compile }
        it { is_expected.to contain_service('varnish-controller-agent').with_ensure('stopped') }
      end

      context 'with custom agent' do
        let(:params) do
          super().merge('agent_name' => 'varnish')
        end

        it { is_expected.to compile }
        it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_AGENT_NAME=varnish"}) }
      end

      context 'with nats port' do
        let(:params) do
          super().merge('nats_server_port' => 1234)
        end

        it { is_expected.to compile }
        it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_NATS_SERVER=127.0.0.1:1234"}) }
      end

      context 'with nats auth' do
        let(:params) do
          super().merge(
            {
              'nats_server_user' => 'foo',
              'nats_server_password' => 'bar',
            }
          )
        end

        it { is_expected.to compile }
        it { is_expected.to contain_systemd__dropin_file('varnish-controller-agent').with_content(%r{Environment="VARNISH_CONTROLLER_NATS_SERVER=foo:bar@127.0.0.1:4222"}) }
      end
    end
  end
end
