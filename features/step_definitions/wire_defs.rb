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
  #@server = IO.popen("./unencumbered")
  Dir.chdir("/tmp") do
    #@server = IO.popen("dub run")
    `dub build`
    @server = IO.popen("./cucumber_test")
  end
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


def write_dub_json
    dub = <<-EOF
{
    "name": "cucumber_test",
    "targetType": "executable",
    "dependencies": {
        "vibe-d": "~master"
    }
}
EOF

  write_file("/tmp/dub.json", dub)
end

def write_app_src
    lines = <<-EOF
import vibe.d;
import std.stdio;
import std.string;

shared static this() {
    setLogLevel(LogLevel.debugV);
    listenTCP_s(54321, &accept);
}

void accept(TCPConnection tcpConnection) {
    while(tcpConnection.connected) {
        auto bytes = tcpConnection.readLine(size_t.max, "\n");
        handle(tcpConnection, (cast(string)bytes).strip());
    }

    if(tcpConnection.connected) tcpConnection.close();
}

void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

void handle(TCPConnection tcpConnection, in string request) {
    debug writeln("\nRequest:\n", request, "\n");
    if(request == `["begin_scenario",{"tags":["wire"]}]`) tcpConnection.send(`["success"]`);
    else {
        debug writeln("oops");
        tcpConnection.send(`["success",[]]`);
    }
}

EOF
  write_file('/tmp/source/app.d', lines)
  puts "/tmp/source/app.d:\n#{lines}"

end

Given(/^there is a wire server running on port (\d+) which understands the following protocol:$/) do |port, table|

  # table is a Cucumber::Ast::Table
  write_dub_json
  write_app_src
  connect_to_server(port)
end
