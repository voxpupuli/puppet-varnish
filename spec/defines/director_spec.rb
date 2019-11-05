require 'spec_helper'

describe 'varnish::director', type: :define do
  let :pre_condition do
    [
      'class { "::varnish": }',
      'class { "::varnish::vcl": }'
    ]
  end
  let(:title) { 'foo' }

  context 'on a Ubuntu 18 OS' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemrelease: '18.04',
        concat_basedir: '/dne',
        lsbdistid: 'Ubuntu',
        lsbdistcodename: 'bionic',
	os: {
	  architecture: "amd64",
	  distro: {
	    codename: "bionic",
	    description: "Ubuntu 18.04.3 LTS",
	    id: "Ubuntu",
	    release: {
	      full: "18.04",
	      major: "18.04"
	    }
	  },
	  family: "Debian",
	  hardware: "x86_64",
	  name: "Ubuntu",
	  release: {
	    full: "18.04",
	    major: "18.04"
	  },
	  selinux: {
	    enabled: false
	  }
	}
      }
    end

    context('expected behaviour') do
      let(:params) { { backends: ['192.168.10.14'] } }

      it { is_expected.to contain_concat__fragment("foo-director").with_content(/new foo/)
      }
    end
  end

  context 'on a Ubuntu 16 OS' do
    let :facts do
      {
	osfamily: 'Debian',
	operatingsystemrelease: '16.04',
	concat_basedir: '/dne',
	lsbdistid: 'Ubuntu',
	lsbdistcodename: 'xenial',
	os: {
	  architecture: "amd64",
	  distro: {
	    codename: "xenial",
	    description: "Ubuntu 16.04.3 LTS",
	    id: "Ubuntu",
	    release: {
	      full: "16.04",
	      major: "16.04"
	    }
	  },
	  family: "Debian",
	  hardware: "x86_64",
	  name: "Ubuntu",
	  release: {
	    full: "16.04",
	    major: "16.04"
	  },
	  selinux: {
	    enabled: false
	  }
	}
      }
    end

    context('expected behaviour') do
      let(:params) { { backends: ['192.168.10.14'] } }

      it { is_expected.to contain_concat__fragment("foo-director").with_content(/new foo/)
      }
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemrelease: '7.6',
        concat_basedir: '/dne',
        os: {
          architecture: 'x86_64',
          family: 'RedHat',
          hardware: 'x86_64',
          name: 'RedHat',
          release: {
            full: '7.6',
            major: '7',
            minor: '6',
          },
          selinux: {
            enabled: false
          }
        }
      }
    end

    context('expected behaviour') do
      let(:params) { { backends: ['192.168.10.14'] } }

      it { is_expected.to contain_concat__fragment("foo-director").with_content(/new foo/)
      }
    end
  end
end
