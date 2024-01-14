# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::vcl::probe', type: :define do
  let :pre_condition do
    '
    '
  end

  let(:title) { 'foo' }
  let(:params) do
    {
      includedir: '/etc/varnish/includes',
    }
  end

  context('expected behaviour') do
    it {
      is_expected.to contain_concat__fragment('foo-probe').with_target('/etc/varnish/includes/probes.vcl')
      is_expected.to contain_concat__fragment('foo-probe').with_content(%r{probe foo \{})
    }

    it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{^# set probe foo\s+probe foo \{\s*\}\s*$}m) }

    context 'with interval' do
      let :params do
        super().merge({
                        interval: '1s',
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.interval = 1s;}) }
    end

    context 'with timeout' do
      let :params do
        super().merge({
                        timeout: '1s',
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.timeout = 1s;}) }
    end

    context 'with timeout as int' do
      let :params do
        super().merge({
                        timeout: 1,
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.timeout = 1;}) }
    end

    context 'with timeout as double' do
      let :params do
        super().merge({
                        timeout: 1.0,
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.timeout = 1.0;}) }
    end

    context 'with threshold' do
      let :params do
        super().merge({
                        threshold: '5',
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.threshold = 5;}) }
    end

    context 'with window' do
      let :params do
        super().merge({
                        window: '5',
                      })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.window = 5;}) }
    end

    context 'with expected_response' do
      let :params do
        super().merge({ expected_response: '404' })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.expected_response = 404;}) }
    end

    context 'with url' do
      let :params do
        super().merge({ url: '/' })
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{\.url = "/";}) }
    end
  end

  context('invalid title') do
    let(:title) { '-wrong_title' }

    it 'causes a failure' do
      is_expected.to compile.and_raise_error(%r{.*})
    end
  end

  context('title != probe_name') do
    let(:params) { super().merge('probe_name' => 'bar') }

    it { is_expected.to contain_concat__fragment('foo-probe').with_content(%r{probe bar \{}) }
  end
end
