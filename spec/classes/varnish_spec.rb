# frozen_string_literal: true

require 'spec_helper'

describe 'varnish', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      # Base Checks for all OS
      it { is_expected.to compile }
      it { is_expected.to contain_class('varnish::install').with('add_repo' => 'false') }

      it {
        is_expected.to contain_class('varnish::service').with('ensure' => 'running')
        is_expected.to contain_systemd__dropin_file('varnish_service').with_unit('varnish.service')
        is_expected.to contain_systemd__dropin_file('varnish_service').with_filename('varnish_override.conf')
        is_expected.to contain_service('varnish').with_ensure('running')
        is_expected.to contain_service('varnish').with(
          'ensure'  => 'running',
          'require' => 'Package[varnish]'
        )
      }

      it { is_expected.to contain_class('varnish::shmlog') }
      it { is_expected.not_to contain_class('varnish::hitch') }

      it {
        is_expected.to contain_file('varnish-conf').with(
          'ensure'  => 'file',
          'path'    => '/etc/varnish/varnish.params',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[varnish]'
          #    'notify'  => 'Service[varnish]',
        )
      }

      it { is_expected.to contain_file('varnish-conf').with_content(%r{START=yes}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{NFILES=131072}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{MEMLOCK=100M}) }
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
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_STORAGE="malloc,\${VARNISH_STORAGE_SIZE}"}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{VARNISH_TTL=120}) }
      it { is_expected.to contain_file('varnish-conf').with_content(%r{DAEMON_OPTS="-a :6081 }) }

      it {
        is_expected.to contain_file('storage-dir').with(
          'ensure' => 'directory',
          'path' => '/var/lib/varnish-storage',
          'require' => 'Package[varnish]'
        )
      }

      if (facts[:osfamily] == 'RedHat') && (facts[:os]['release']['major'] == '7')
        it { is_expected.to contain_file('varnish-conf').without_content(%r{\s  -j unix,user=vcache}) }
      else
        it { is_expected.to contain_file('varnish-conf').with_content(%r{\s  -j unix,user=vcache}) }
      end

      context 'with extra varnish-conf values' do
        let :params do
          { additional_parameters: {
            thread_pools: 4
          } }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('varnish-conf').with_content(%r{-p thread_pools=4}) }
      end

      context 'enable proxy port' do
        let :params do
          { varnish_proxy_listen_port: 8443 }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('varnish-conf').with_content(%r{-a 127.0.0.1:8443,PROXY}) }
      end

      context 'with custom configfile' do
        let :params do
          {
            conf_file_path: '/etc/varnish.params'
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('varnish-conf').with_path('/etc/varnish.params') }
        it { is_expected.to contain_systemd__dropin_file('varnish_service').with_content(%r{EnvironmentFile=-/etc/varnish.params}) }
      end

      # With stopped Ensure for Service
      context 'with stopped ensure' do
        let :params do
          { service_ensure: 'stopped' }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_class('varnish::service').with('ensure' => 'stopped')
          is_expected.to contain_systemd__dropin_file('varnish_service').with_unit('varnish.service')
          is_expected.to contain_systemd__dropin_file('varnish_service').with_filename('varnish_override.conf')
          is_expected.to contain_service('varnish').with_ensure('stopped')
          is_expected.to contain_service('varnish').with(
            'ensure'  => 'stopped',
            'require' => 'Package[varnish]'
          )
        }
      end

      context 'without shmlog_tempfs' do
        let :params do
          { shmlog_tempfs: false }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_class('varnish::shmlog') }
      end

      context 'Manual Set Version' do
        let :params do
          { version: '6.0.0-manual' }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('varnish::install').with_version('6.0.0-manual') }
        it { is_expected.to contain_file('varnish-conf').with_content(%r{\s  -j unix,user=vcache}) }
      end

      context 'Storage Type MSE' do
        let :params do
          { storage_type: 'mse' }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('varnish-conf').with_content(%r{\s -s mse}) }
        it { is_expected.not_to contain_file('varnish-conf').with_content(%r{\s -s mse,/etc/varnish/mse.conf}) }
        it { is_expected.not_to contain_exec('varnish-mkfs-mse') }
      end

      context 'Storage Type MSE with custom config' do
        let :params do
          {
            storage_type: 'mse',
            mse_config: 'env: {
              id = "mse";
              memcache_size = "auto";
              books = ( {
                      id = "book";
                      directory = "/var/lib/mse/book";
                      database_size = "2G";
                      stores = ( {
                              id = "store";
                              filename = "/var/lib/mse/store.dat";
                              size = "100G";
                              } );
                      } );
              };'
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_file('varnish-conf').with_content(%r{\s -s mse \\}) }
        it { is_expected.to contain_file('varnish-conf').with_content(%r{\s -s mse,/etc/varnish/mse.conf}) }

        it { is_expected.to contain_file('varnish-mse-conf').with_path('/etc/varnish/mse.conf') }

        it {
          is_expected.to contain_file('varnish-mse-conf').with_content('env: {
              id = "mse";
              memcache_size = "auto";
              books = ( {
                      id = "book";
                      directory = "/var/lib/mse/book";
                      database_size = "2G";
                      stores = ( {
                              id = "store";
                              filename = "/var/lib/mse/store.dat";
                              size = "100G";
                              } );
                      } );
              };')
        }

        it { is_expected.to contain_exec('varnish-mkfs-mse') }
      end

      context 'Varnish Enterprise' do
        let :params do
          { varnish_enterprise: true }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('varnish::install') }
        it { is_expected.to contain_class('varnish::install').with_varnish_enterprise(true) }

        it {
          is_expected.to contain_package('varnish').with(
            'ensure' => 'present',
            'name'   => 'varnish-plus'
          )
        }
      end

      context 'Hitch enabled' do
        let :params do
          { add_hitch: true }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_class('varnish::hitch') }
      end
    end
  end
end
