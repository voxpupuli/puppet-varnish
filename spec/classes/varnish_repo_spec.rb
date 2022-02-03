require 'spec_helper'

describe 'varnish::repo', type: :class do
  # let(:pre_condition) { 'include ::varnish' }

  context 'on a Debian OS' do
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        operatingsystem: 'Debian',
        lsbdistcodename: 'foo',
        os: {
          architecture: 'amd64',
          distro: {
            codename: 'jessie',
            description: 'Debian GNU/Linux 8.11 (jessie)',
            id: 'Debian',
            release: {
              full: '8.11',
              major: '8',
              minor: '11',
            },
          },
          family: 'Debian',
          hardware: 'x86_64',
          name: 'Debian',
          release: {
            full: '8.11',
            major: '8',
            minor: '11',
          },
          selinux: {
            enabled: false,
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.not_to contain_apt__source('varnish') }
    it { is_expected.not_to contain_yumrepo('varnish') }
    context 'enabled Repo' do
      let :params do
        { enable: true }
      end

      it {
        is_expected.to contain_apt__source('varnish').with(
          'location'   => 'https://packagecloud.io/varnishcache/varnish60lts/ubuntu/',
          'repos'      => 'varnish-60lts',
          'key'        => {
            'id'     => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD',
            'source' => 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey',
          },
        )
      }
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        operatingsystemrelease: '7.4',
        architecture: 'x86_64',
      }
    end

    it { is_expected.to compile }
    it { is_expected.not_to contain_apt__source('varnish') }
    it { is_expected.not_to contain_yumrepo('varnish') }
    context 'enabled Repo' do
      let :params do
        { enable: true }
      end

      it {
        is_expected.to contain_yumrepo('varnish').with(
          'enabled' => '1',
          'baseurl' => 'https://packagecloud.io/varnishcache/varnish60lts/el/7/x86_64',
        )
      }
    end
  end

  context 'on an Amazon OS' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystem: 'Amazon',
        operatingsystemrelease: '3.4.82-69.112.amzn1.x86_64',
        architecture: 'x86_64',
      }
    end

    it { is_expected.to compile }
    it { is_expected.not_to contain_apt__source('varnish') }
    it { is_expected.not_to contain_yumrepo('varnish') }
    context 'enabled Repo' do
      let :params do
        { enable: true }
      end

      it {
        is_expected.to contain_yumrepo('varnish').with(
          'enabled' => '1',
          'baseurl' => 'https://packagecloud.io/varnishcache/varnish60lts/el/6/x86_64',
        )
      }
    end
  end
end
