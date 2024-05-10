module Proxies
  class TorProxy
    LOCALHOST = '127.0.0.1'

    class << self
      include LogHelper

      START_PORT = 9250
      START_CONTROL_PORT = 52500

      attr_reader :listen_port, :control_port

      def tor_process
        if @tor_process.present? && @listen_port.present? && running?(port: @listen_port)
          return @tor_process
        end

        stop_all_tor!
        _configs = configs

        @tor_process ||= TorManager::TorProcess.new(_configs)
        @tor_process.start unless running?(port: _configs[:tor_port])
        @tor_process
      end

      def running?(port: START_PORT)
        TorManager::TorProcess.tor_running_on? port: port
      end

      def stop_all_tor!
        TorManager::TorProcess.stop_obsolete_processes
      end

      def wrap(&block)
        tor_proxy.proxy &block
      end

      def tor_proxy
        @tor_proxy ||= TorManager::Proxy.new tor_process: tor_process
      end

      def stop!
        @tor_process&.stop
        if running?
          false
        else
          @tor_process = nil
          @tor_ip_control = nil
          @listen_port = nil
          @control_port = nil
          true
        end
      end

      def tor_ip_control
        @tor_ip_control ||= TorManager::IpAddressControl.new tor_process: tor_process,
                                                             tor_proxy: tor_proxy
      end

      def new_ip!
        log_info self.name, tor_ip: tor_ip_control.get_new_ip
      end

      def ip
        tor_ip_control.ip
      end

      def configs
        # --ExitNodes {US} --StrictNodes 1
        {
          pid_dir: extend_path('tor'),
          log_dir: extend_path('tor'),
          tor_data_dir: extend_path('tor/data'),
          tor_new_circuit_period: 10,
          max_tor_memory_usage_mb: 256,
          max_tor_cpu_percentage: 15,
          # control_password: 'mycontrolpass',
          eye_logging: false,
          tor_logging: false
        }.merge next_listen_port
      end

      def next_listen_port
        @listen_port ||= START_PORT
        @control_port ||= START_CONTROL_PORT

        while running?(port: @listen_port)
          @listen_port += 1
          @control_port += 1
        end

        log_info self.name, listen_port: @listen_port, control_port: @control_port

        {
          tor_port: @listen_port,
          control_port: @control_port
        }
      end

      def extend_path(path)
        File.join Rails.root.to_s, path
      end

      def proxy_options
        tor_process unless running?

        "socks5://#{ LOCALHOST }:#{ listen_port }"
      end
    end
  end
end
