require 'spec_helper'

describe 'varnish::firewall', type: :class do
  context 'default values' do
    it { is_expected.to compile }
    it { is_expected.not_to contain_firewall('100 allow port 6081 to varnish') }
  end

  context 'varnish Enterprise' do
    let :params do
      {
        manage_firewall: true,
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_firewall('100 allow port 6081 to varnish') }
  end
end
