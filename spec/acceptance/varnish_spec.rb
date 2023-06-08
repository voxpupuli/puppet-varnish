# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Varnish class' do
  context 'minimal parameters', 'init.pp' do
    # Using puppet_apply as a helper
    # it_behaves_like 'init', 'init.pp'
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'varnish':
      }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe port(6081) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe port(6082) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end

    describe service('varnish') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    it 'responds with the page' do
      shell('/usr/bin/curl http://127.0.0.1:6081/') do |r|
        expect(r.stdout).to match(%r{Varnish})
      end
    end
  end

  context 'Custom Listen Port' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'varnish':
        varnish_listen_port => 8080,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe port(8080) do
      it { is_expected.to be_listening }
    end

    it 'responds with the page' do
      shell('/usr/bin/curl http://127.0.0.1:8080/') do |r|
        expect(r.stdout).to match(%r{Varnish}i)
      end
    end
  end

  context 'Custom Backend' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'varnish':
      }
      class { 'varnish::vcl':
        backends => { 'default' => { host => '127.0.0.1', port => 80 }},
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'responds with the page' do
      shell('/usr/bin/curl http://127.0.0.1:6081/') do |r|
        expect(r.stdout).to match(%r{nginx}i)
      end
    end
  end
end
