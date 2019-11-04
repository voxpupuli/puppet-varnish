require 'spec_helper'

# TODO: add more sophisticated tests, but for
# now you can't rspec concat content

describe 'varnish::vcl', type: :class do
  context 'default values' do
    let :facts do
      {
        concat_basedir: '/dne',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('varnish') }
    it {
      is_expected.to contain_file('varnish-vcl').with(
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[varnish]',
        'notify'  => 'Service[varnish]',
      )
    }
  end
end
