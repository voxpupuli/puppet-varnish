require 'spec_helper'

describe 'varnish::service', type: :class do
  context 'on a Debian OS family' do
    let(:pre_condition) { 'include ::varnish' }
    let :facts do
      {
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        operatingsystem: 'Debian',
        lsbdistcodename: 'foo',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('varnish::install') }

    it {
      is_expected.to contain_service('varnish').with(
        'ensure'  => 'running',
        'restart' => '/etc/init.d/varnish reload',
        'require' => 'Package[varnish]',
      )
    }
  end

  context 'on a RedHat OS family and sisabled' do
    let(:pre_condition) { 'include ::varnish' }
    let :facts do
      {
        osfamily: 'RedHat',
      }
    end

    let(:params) { { start: 'no' } }

    xit { is_expected.to compile }
    xit { is_expected.to contain_class('varnish::install') }

    xit {
      is_expected.to contain_service('varnish').with(
        'ensure'  => 'stopped',
        'restart' => '/sbin/service varnish reload',
        'require' => 'Package[varnish]',
      )
    }
  end
end
