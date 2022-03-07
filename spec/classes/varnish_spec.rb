require 'spec_helper'

describe 'varnish', type: :class do
  context 'on a Debian OS' do
    let :facts do
      {
        architecture: 'amd64',
        osfamily: 'Debian',
        operatingsystemrelease: '8',
        concat_basedir: '/dne',
        lsbdistid: 'Debian',
        lsbdistcodename: 'jessie',
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
    it { is_expected.to contain_class('varnish::install').with('add_repo' => 'false') }
    it { is_expected.to contain_class('varnish::service').with('start' => 'yes') }
    it { is_expected.to contain_class('varnish::shmlog') }
    it { is_expected.to contain_class('varnish::params') }
    it {
      is_expected.to contain_file('varnish-conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/varnish/varnish.params',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[varnish]',
        #    'notify'  => 'Service[varnish]',
      )
    }
    it {
      is_expected.to contain_file('storage-dir').with(
        'ensure' => 'directory',
        'path' => '/var/lib/varnish-storage',
        'require' => 'Package[varnish]',
      )
    }

    context 'without shmlog_tempfs' do
      let :params do
        { shmlog_tempfs: false }
      end

      it { is_expected.not_to contain_class('varnish::shmlog') }
    end

    context 'Varnish Enterprise' do
      let :params do
        { varnish_enterprise: true }
      end

      it { is_expected.to contain_class('varnish::install') }
      it { is_expected.to contain_class('varnish::install').with_varnish_enterprise(true) }

      it {
        is_expected.to contain_package('varnish').with(
          'ensure' => 'present',
          'name'   => 'varnish-plus',
        )
      }
    end

    context 'default varnish-conf values' do
      it { is_expected.to contain_file('varnish-conf').with_content(%r{START=yes}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{NFILES=131072}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{MEMLOCK=82000}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_VCL_CONF=/etc/varnish/default.vcl}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_LISTEN_ADDRESS=}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_LISTEN_PORT=6081}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_ADMIN_LISTEN_ADDRESS=(localhost|127.0.0.1)}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_ADMIN_LISTEN_PORT=6082}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_MIN_THREADS=5}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_MAX_THREADS=500}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_THREAD_TIMEOUT=300}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_STORAGE_FILE=/var/lib/varnish-storage/varnish_storage.bin}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_STORAGE_SIZE=1G}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_SECRET_FILE=/etc/varnish/secret}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_STORAGE=\"malloc,\${VARNISH_STORAGE_SIZE}\"}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_TTL=120}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{DAEMON_OPTS=\"-a :6081 }) }
    end
  end

  context 'on a RedHat' do
    let :facts do
      {
        osfamily: 'RedHat',
        concat_basedir: '/dne',
        operatingsystem: 'RedHat',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('varnish::install').with('add_repo' => 'false') }
    it { is_expected.to contain_class('varnish::service').with('start' => 'yes') }
    it { is_expected.to contain_class('varnish::shmlog') }
    it {
      is_expected.to contain_file('varnish-conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/varnish/varnish.params',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[varnish]',
        # 'notify'  => 'Service[varnish]',
      )
    }
    it {
      is_expected.to contain_file('storage-dir').with(
        'ensure' => 'directory',
        'path' => '/var/lib/varnish-storage',
        'require' => 'Package[varnish]',
      )
    }
    context 'without shmlog_tempfs' do
      let :params do
        { shmlog_tempfs: false }
      end

      it { is_expected.not_to contain_class('varnish::shmlog') }
    end

    context 'enable proxy port' do
      let :params do
        { varnish_proxy_listen_port: 8443 }
      end

      it { is_expected.to contain_file('varnish-conf').with_content(%r{-a 127.0.0.1:8443,PROXY}) }
    end
  end

  context 'on a Ubuntu OS' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemrelease: '18.04',
        concat_basedir: '/dne',
        lsbdistid: 'Ubuntu',
        lsbdistcodename: 'bionic',
        os: {
          architecture: 'amd64',
          distro: {
            codename: 'bionic',
            description: 'Ubuntu 18.04.5 LTS',
            id: 'Ubuntu',
            release: {
              full: '18.04',
              major: '18.04',
            },
          },
          family: 'Debian',
          hardware: 'x86_64',
          name: 'Ubuntu',
          release: {
            full: '18.04',
            major: '18.04',
          },
          selinux: {
            enabled: false,
          },
        },
      }
    end

    it { is_expected.to compile }

    it {
      is_expected.to contain_package('varnish').with(
        'ensure' => 'present',
      )
    }
  end
end
