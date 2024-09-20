# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::repo', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'without params' do
        it { is_expected.to compile }
        it { is_expected.not_to contain_apt__source('varnish') }
        it { is_expected.not_to contain_yumrepo('varnish') }
      end

      context 'enabled Repo' do
        let :params do
          { enable: true }
        end

        it { is_expected.to compile }

        case os_facts['os']['family']
        when 'Debian'
          it {
            is_expected.to contain_apt__source('varnish').with(
              'location' => 'https://packagecloud.io/varnishcache/varnish60lts/ubuntu/',
              'repos' => 'varnish-60lts',
              'key' => {
                'id'     => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD',
                'source' => 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey',
              }
            )
          }
        when 'Redhat'
          it {
            is_expected.to contain_yumrepo('varnish').with(
              'enabled' => '1',
              'baseurl' => 'https://packagecloud.io/varnishcache/varnish60lts/el/7/x86_64'
            )
          }
        end
      end
    end
  end
end
