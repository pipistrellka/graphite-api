require_relative "../minitest_helper"

module GraphiteAPI
  class ConnectorTester < Unit::TestCase
    def test_initialize_tcp
      Connector::TCPSocket.expects(:new).with('localhost',2003).returns(:socket)
      Connector.new('localhost',2003).tap do |obj|
        assert_equal :socket, obj.instance_variable_get(:@socket)
      end
    end

    def test_initialize_udp
      Connector::UDPSocket.expects(:new).with('localhost',2003).returns(:socket)
      Connector.new('localhost',2003, 'udp').tap do |obj|
        assert_equal :socket, obj.instance_variable_get(:@socket)
      end
    end
  end
end
