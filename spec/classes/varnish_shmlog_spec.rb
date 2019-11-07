require 'spec_helper'

describe 'varnish::shmlog', type: :class do
  context 'default values' do
    it { is_expected.to compile }
    it {
      is_expected.to contain_file('shmlog-dir').with(
        'ensure' => 'directory',
        'path' => '/var/lib/varnish',
      )
    }
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
