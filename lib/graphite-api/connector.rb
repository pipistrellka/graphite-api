# -----------------------------------------------------
# TCP Socket connection
# -----------------------------------------------------
# Usage:
#    connector = GraphiteAPI::Connector.new("localhost",2003)
#    connector.puts("my.metric 1092 1232123231")
#
# Socket:
# => my.metric 1092 1232123231\n
# -----------------------------------------------------
require 'socket'

module GraphiteAPI
  class Connector
    class Group
      def initialize options
        @connectors = options[:backends].map { |o| Connector.new(*o) }
      end

      def publish messages
        Logger.debug [:connector_group, :publish, messages.size, @connectors]
        Array(messages).each { |msg| @connectors.map {|c| c.puts msg} }
      end
    end

    def initialize host, port, scheme='tcp'
      @socket = scheme == 'udp' ? UDPSocket.new(host, port) : TCPSocket.new(host, port)
    end
    
    def puts message
      begin
        Logger.debug [:connector,:puts,@socket.inspect,message]
        @socket.puts message + "\n"
      rescue Errno::EPIPE, Errno::EINVAL, Errno::ETIMEDOUT
        @socket.reopen
      retry
      end
    end
    
    def inspect
      "#{self.class} #{@socket.inspect}"
    end

    class Socket
      def initialize host, port
        @host, @port = host, port
      end

      def inspect
        "#{self.class} #{@host}:#{@port}"
      end

      def reopen
        @socket = nil
      end
    end

    class UDPSocket < Socket
      def puts message
        socket.send message + "\n", 0
      end

      private

      def socket
        if @socket.nil? || @socket.closed?
          Logger.debug [:connector,[@host,@port,'udp']]
          @socket = ::UDPSocket.new
          @socket.connect @host, @port
        end
        @socket
      end
    end

    class TCPSocket < Socket
      def puts message
        socket.puts message + "\n"
      end

      private

      def socket
        if @socket.nil? || @socket.closed?
          Logger.debug [:connector,[@host,@port,'tcp']]
          @socket = ::TCPSocket.new @host, @port
        end
        @socket
      end
    end
    
  end
end
