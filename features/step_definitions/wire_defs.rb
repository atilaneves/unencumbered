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
    },
    "versions": ["VibeDefaultMain"]
}
EOF

  write_file("/tmp/dub.json", dub)
end

def get_regexps(requests, responses)
  puts "responses are #{responses}"
  response_infos = responses.map { |r| r[1] }
  regexps = []
  puts "responseinfos are #{response_infos}"
  response_infos.each do |response|
    response.each do |info|
      puts "info is #{info}"
      if not info.keys.include?('regexp')
        return requests.map { |r| r[0] == "step_matches" ? r[1]["name_to_match"] : ""}
      end
      regexps << info['regexp']
    end
  end
  regexps
end


def get_funcs_string(responses, regexps)
  funcs = ""
  idx = 1
  responses.each do |response|
    regexp = regexps.shift
    if response[1].length > 0
      funcs += "@Match!r\"#{regexp}\"\n"
    else
      funcs += "@Match!r\"falkacpioiwervl\"\n"
    end

    funcs += "void func_#{idx}() { }\n"
    idx += 1
  end
  funcs
end

def get_details_string(responses)
  responses.map { |r| r[1] }.each do |response|
    response.each do |info|
      if info.keys.include? "source"
        return ", Yes.details"
      end
    end
  end
  ""
end

def write_app_src(port, table)
  requests = table.hashes.map {|h| JSON.parse(h["request"])}
  responses = table.hashes.map {|h| JSON.parse(h["response"])}
  regexps = get_regexps(requests, responses)
  funcs = get_funcs_string(responses, regexps)
  details = get_details_string(responses)

  lines = <<-EOF
module cucumber.app;

import cucumber.server;
import cucumber.keywords;
import vibe.d;
import std.stdio;

#{funcs}

shared static this() {
    debug {
        setLogLevel(LogLevel.debugV);
        writeln("Running the Cucumber server");
    }

    runCucumberServer!__MODULE__(#{port}#{details});
}

EOF

  write_file('/tmp/source/cucumber/app.d', lines)
  puts "/tmp/source/cucumber/app.d:\n#{lines}"

end

def copy_unencumbered
  FileUtils.cp_r(get_absolute_path("../source"), "/tmp/")
end

Given(/^there is a wire server running on port (\d+) which understands the following protocol:$/) do |port, table|
  # table is a Cucumber::Ast::Table
  puts "table is #{table}"
  copy_unencumbered
  write_dub_json
  write_app_src(port, table)
  connect_to_server(port)
end
