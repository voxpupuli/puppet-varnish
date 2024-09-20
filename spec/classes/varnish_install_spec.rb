# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::install', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'default values' do
        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => 'present',
            'name'   => 'varnish'
          )
        }

        it {
          is_expected.to contain_package('varnish-absent').with(
            'ensure' => 'absent',
            'name'   => 'varnish-plus'
          )
        }

        it { is_expected.to contain_class('varnish::repo') }
        it { is_expected.to contain_class('varnish::firewall') }
      end

      context 'varnish Enterprise' do
        let :params do
          {
            varnish_enterprise: true,
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => 'present',
            'name'   => 'varnish-plus'
          )
        }

        it {
          is_expected.to contain_package('varnish-absent').with(
            'ensure' => 'absent',
            'name'   => 'varnish'
          )
        }

        it { is_expected.to contain_class('varnish::repo') }
        it { is_expected.to contain_class('varnish::firewall') }
      end

      context 'varnish Enterprise + extra vmods' do
        let :params do
          {
            varnish_enterprise: true,
            varnish_enterprise_vmods_extra: true,
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => 'present',
            'name'   => 'varnish-plus'
          )
        }

        it {
          is_expected.to contain_package('varnish-plus-vmods-extra').with(
            'ensure' => 'present',
            'name'   => 'varnish-plus-vmods-extra'
          )
        }

        it {
          is_expected.to contain_package('varnish-absent').with(
            'ensure' => 'absent',
            'name'   => 'varnish'
          )
        }
      end

      context 'varnish Custom Package' do
        let :params do
          {
            package_name: 'varnish-custom',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => 'present',
            'name'   => 'varnish-custom'
          )
        }

        it { is_expected.to contain_class('varnish::repo') }
        it { is_expected.to contain_class('varnish::firewall') }
      end

      context 'varnish 6.0' do
        let :params do
          {
            version: '6.0',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => '6.0',
            'name'   => 'varnish'
          )
        }

        it {
          is_expected.to contain_package('varnish-absent').with(
            'ensure' => 'absent',
            'name'   => 'varnish-plus'
          )
        }

        it { is_expected.to contain_class('varnish::repo') }
        it { is_expected.to contain_class('varnish::firewall') }
      end
    end
  end
end
