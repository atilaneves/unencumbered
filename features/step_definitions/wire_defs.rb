require 'socket'
require 'timeout'

After do
  @socket.nil? or @socket.close
  if not @server.nil?
    Process.kill("INT", @server.pid)
    Process.wait(@server.pid)
  end
end

def connect_to_server(port=54321)
  @server = IO.popen("./unencumbered")
  Timeout.timeout(5) do
    while @socket.nil?
      begin
        @socket = TCPSocket.new('localhost', port)
      rescue Errno::ECONNREFUSED
        #keep trying until the server is up or we time out
      end
    end
  end
end


Given(/^there is a wire server running on port (\d+) which understands the following protocol:$/) do |port, table|
  # table is a Cucumber::Ast::Table
  connect_to_server(port)
end
