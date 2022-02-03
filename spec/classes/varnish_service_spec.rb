require 'spec_helper'

describe 'varnish::service', type: :class do
  context 'on a Debian OS family' do
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
    it { is_expected.to contain_class('varnish::install') }
    it { is_expected.to contain_systemd__dropin_file('varnish_service').with_unit('varnish.service') }
    it { is_expected.to contain_systemd__dropin_file('varnish_service').with_filename('varnish_override.conf') }
    it { is_expected.to contain_service('varnish').with_ensure('running') }
    it {
      is_expected.to contain_service('varnish').with(
        'ensure'  => 'running',
        'require' => 'Package[varnish]',
      )
    }

    context 'old stuff' do
      let :facts do
        {
          osfamily: 'Debian',
          lsbdistid: 'Debian',
          operatingsystem: 'Debian',
          lsbdistcodename: 'foo',
          os: {
            architecture: 'amd64',
            distro: {
              codename: 'wheezy',
              description: 'Debian GNU/Linux 7.11 (wheezy)',
              id: 'Debian',
              release: {
                full: '7.11',
                major: '7',
                minor: '11',
              },
            },
            family: 'Debian',
            hardware: 'x86_64',
            name: 'Debian',
            release: {
              full: '7.11',
              major: '7',
              minor: '11',
            },
            selinux: {
              enabled: false,
            },
          },
        }
      end

      it { is_expected.not_to compile }
    end
  end

  context 'on a RedHat OS family' do
    let :facts do
      {
        osfamily: 'RedHat',
      }
    end

    it { is_expected.to contain_systemd__dropin_file('varnish_service').with_unit('varnish.service') }
    it { is_expected.to contain_systemd__dropin_file('varnish_service').with_filename('varnish_override.conf') }
    it { is_expected.to contain_service('varnish').with_ensure('running') }
    it {
      is_expected.to contain_service('varnish').with(
        'ensure'  => 'running',
        'require' => 'Package[varnish]',
      )
    }
    context 'disabled' do
      let(:params) { { start: 'no' } }

      it { is_expected.to compile }

      it do
        is_expected.to contain_service('varnish').with(
          'ensure'  => 'stopped',
          'require' => 'Package[varnish]',
        )
      end
    end
  end
end
