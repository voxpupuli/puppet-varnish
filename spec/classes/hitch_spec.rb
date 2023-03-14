# frozen_string_literal: true

require 'spec_helper'

describe 'varnish::hitch' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge('processors' => { 'count' => 4 }) }
      let :params do
        {
          pem_files: ['/etc/varnish/cert.pem'],
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('hitch').with('ensure' => 'present', 'name' => 'varnish-plus-addon-ssl') }
      it { is_expected.to contain_service('hitch').with('ensure' => 'running', 'name' => 'hitch') }
      it { is_expected.to contain_service('hitch').that_requires('Package[hitch]') }
      it { is_expected.to contain_service('hitch').that_subscribes_to('File[hitch-conf]') }

      it {
        is_expected.to contain_file('hitch-conf').with(
          'ensure' => 'file',
          'path' => '/etc/hitch/hitch.conf',
          'owner' => 'root',
          'group' => 'root',
          'mode' => '0644'
        )
      }

      it { is_expected.to contain_file('hitch-conf').that_requires('Package[hitch]') }
      it { is_expected.to contain_file('hitch-conf').that_notifies('Service[hitch]') }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{frontend = {\n\s+host = "\*"\n\s+port = "443"\n}}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{backend = "\[127.0.0.1\]:8443"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{pem-file = "/etc/varnish/cert.pem"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{tls-protos = TLSv1.2 TLSv1.3}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{ciphers = "EECDH\+AESGCM:EDH\+AESGCM"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{ciphersuites = "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{ssl-engine = ""}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{workers = 4}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{backlog = 200}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{keepalive = 3600}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{chroot = ""}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{user = "hitch"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{group = "hitch"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{log-level = 1}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{syslog = on}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{syslog-facility = "daemon"}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{daemon = on}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{write-ip = off}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{write-proxy-v1 = off}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{write-proxy-v2 = on}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{proxy-proxy = off}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{sni-nomatch-abort = off}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{tcp-fastopen = off}) }
      it { is_expected.to contain_file('hitch-conf').with_content(%r{alpn-protos = "h2,http/1.1"}) }

      context 'with Package version' do
        let(:params) do
          super().merge('package_ensure' => '1.0.1')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('hitch').with('ensure' => '1.0.1', 'name' => 'varnish-plus-addon-ssl') }
      end

      context 'with Package name' do
        let(:params) do
          super().merge('package_name' => 'hitch')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('hitch').with('ensure' => 'present', 'name' => 'hitch') }
      end

      context 'with Service ensure' do
        let(:params) do
          super().merge('service_ensure' => 'stopped')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('hitch').with('ensure' => 'stopped', 'name' => 'hitch') }
      end

      context 'with Service name' do
        let(:params) do
          super().merge('service_name' => 'foo')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('hitch').with('ensure' => 'running', 'name' => 'foo') }
      end

      context 'with multiple pemfiles' do
        let :params do
          {
            pem_files: ['/etc/varnish/cert.pem', '/etc/varnish/cert1.pem'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('hitch-conf').with_content(%r{pem-file = "/etc/varnish/cert.pem"\npem-file = "/etc/varnish/cert1.pem"}) }
      end

      context 'with config file path' do
        let(:params) do
          super().merge('config_path' => '/etc/hitch/test.conf')
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('hitch-conf').with_path('/etc/hitch/test.conf') }
      end

      context 'with multiple frontends' do
        let(:params) do
          super().merge(frontends: [{ 'host' => '*', 'port' => 443, }, { 'host' => 'demo.example.com', 'port' => 8443, }])
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('hitch-conf').with_content(%r{frontend = {\n\s+host = "\*"\n\s+port = "443"\n}}) }
        it { is_expected.to contain_file('hitch-conf').with_content(%r{frontend = {\n\s+host = "demo.example.com"\n\s+port = "8443"\n}}) }
      end

      [
        {
          title: 'manual backend',
          param_add: { 'backend' => '[127.0.0.2]:8443' },
          check: %r{backend = "\[127.0.0.2\]:8443"},
        },
        {
          title: 'manual tls protos',
          param_add: { 'tls_protos' => 'TLSv1.3' },
          check: %r{tls-protos = TLSv1.3},
        },
        {
          title: 'manual ciphers',
          param_add: { 'ciphers' => 'EECDH+AESGCM' },
          check: %r{ciphers = "EECDH\+AESGCM"},
        },
        {
          title: 'manual ciphersuites',
          param_add: { 'ciphersuites' => 'TLS_AES_256_GCM_SHA384' },
          check: %r{ciphersuites = "TLS_AES_256_GCM_SHA384"},
        },
        {
          title: 'manual ssl_engine',
          param_add: { 'ssl_engine' => 'foo' },
          check: %r{ssl-engine = "foo"},
        },
        {
          title: 'manual workers',
          param_add: { 'workers' => 2 },
          check: %r{workers = 2},
        },
        {
          title: 'manual backlog',
          param_add: { 'backlog' => 2 },
          check: %r{backlog = 2},
        },
        {
          title: 'manual keepalive',
          param_add: { 'keepalive' => 2 },
          check: %r{keepalive = 2},
        },
        {
          title: 'manual chroot',
          param_add: { 'chroot' => '/foo' },
          check: %r{chroot = "/foo"},
        },
        {
          title: 'manual user',
          param_add: { 'user' => 'foo' },
          check: %r{user = "foo"},
        },
        {
          title: 'manual group',
          param_add: { 'group' => 'foo' },
          check: %r{group = "foo"},
        },
        {
          title: 'manual log-level',
          param_add: { 'log_level' => 2 },
          check: %r{log-level = 2},
        },
        {
          title: 'manual syslog_facility',
          param_add: { 'syslog_facility' => 'local3' },
          check: %r{syslog-facility = "local3"},
        },
        {
          title: 'manual syslog',
          param_add: { 'syslog' => false },
          check: %r{syslog = off},
        },
        {
          title: 'manual daemon',
          param_add: { 'daemon' => false },
          check: %r{daemon = off},
        },
        {
          title: 'manual sni_nomatch_abort',
          param_add: { 'sni_nomatch_abort' => true },
          check: %r{sni-nomatch-abort = on},
        },
        {
          title: 'manual tcp_fastopen',
          param_add: { 'tcp_fastopen' => true },
          check: %r{tcp-fastopen = on},
        },
        {
          title: 'manual alpn_protos',
          param_add: { 'alpn_protos' => 'foo' },
          check: %r{alpn-protos = "foo"},
        },
        {
          title: 'manual additional_parameters',
          param_add: { 'additional_parameters' => { 'param' => 'foo' } },
          check: %r{param = "foo"},
        },
        {
          title: 'manual additional_parameters',
          param_add: { 'additional_parameters' => { 'param' => 2 } },
          check: %r{param = 2},
        },
      ].each do |param|
        context "with #{param[:title]}" do
          let(:params) do
            super().merge(param[:param_add])
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('hitch-conf').with_content(param[:check]) }
        end
      end
    end
  end
end
