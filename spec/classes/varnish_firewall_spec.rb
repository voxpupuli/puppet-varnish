# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::firewall', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'default values' do
        it { is_expected.to compile }
        it { is_expected.not_to contain_firewall('100 allow port 6081 to varnish') }
      end

      context 'manage firewall' do
        let :params do
          {
            manage_firewall: true,
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_firewall('100 allow port 6081 to varnish') }

        context 'with custom port' do
          let :params do
            {
              manage_firewall: true,
              varnish_listen_port: 80,
            }
          end

          it { is_expected.to compile }
          it { is_expected.to contain_firewall('100 allow port 80 to varnish') }
        end
      end
    end
  end
end
