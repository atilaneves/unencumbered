require 'socket'
require 'timeout'
require 'json'

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

def write_app_src(port, table)
    requests = table.hashes.map {|h| JSON.parse(h["request"])}
    regexps = requests.map { |r| r[0] == "step_matches" ? r[1]["name_to_match"] : ""}

    lines = <<-EOF
import cucumber;

@Match!r\"#{regexps[0]}\"
void match() {
}

shared static this() {
    runCucumberServer!__MODULE__(#{port});
}

EOF

  write_file('/tmp/source/app.d', lines)
  puts "/tmp/source/app.d:\n#{lines}"

end

def copy_unencumbered
  FileUtils.cp_r(get_absolute_path("../source"), "/tmp/source")
end

Given(/^there is a wire server running on port (\d+) which understands the following protocol:$/) do |port, table|

  # table is a Cucumber::Ast::Table
  copy_unencumbered
  write_dub_json
  write_app_src(port, table)
  connect_to_server(port)
end
