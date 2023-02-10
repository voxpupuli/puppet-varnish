require 'spec_helper'

describe 'varnish::shmlog', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'default values' do
        it { is_expected.to compile }
        it {
          is_expected.to contain_file('shmlog-dir').with(
            'ensure' => 'directory',
            'path' => '/var/lib/varnish',
          )
        }
        if facts[:os]['selinux']['enabled'] == true
          it {
            is_expected.to contain_mount('shmlog-mount').with(
              'target'  => '/etc/fstab',
              'fstype'  => 'tmpfs',
              'device'  => 'tmpfs',
              'options' => 'defaults,noatime,size=170M,rootcontext=system_u:object_r:varnishd_var_lib_t:s0',
            )
          }
        else
          it {
            is_expected.to contain_mount('shmlog-mount').with(
              'target'  => '/etc/fstab',
              'fstype'  => 'tmpfs',
              'device'  => 'tmpfs',
              'options' => 'defaults,noatime,size=170M',
            )
          }
        end
      end
    end
  end
end
