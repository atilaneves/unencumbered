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
  Dir.chdir("/tmp") do
    `dub build --force`
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

    _write_file("/tmp/dub.json", dub)
end

def _write_file(filename, str)
  Dir.exist?(File.dirname(filename)) or Dir.mkdir(File.dirname(filename))
  File.open(filename, 'w') { |file| file.write(str)}
end

def get_regexps(requests, responses)
  response_infos = responses.map { |r| r[1] }
  regexps = []
  response_infos.each do |response|
    response.each do |info|
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
  responses.each do |r|
    puts "r is #{r}"
    if r.length > 1 && r[1].class == Array && !r[1].empty? && !r[1][0].empty? && r[1][0].class == Hash && r[1][0].has_key?("source")
      funcs += "\n" * 115 # to match the source line number
    end
  end
  regexp = regexps.shift
  response = responses[0]

  if response[1].length > 0
    funcs += "@Given(r\"#{regexp}\")\n"
  else
    funcs += "@Given(r\"falkacpioiwervl\")\n"
  end

  funcs += "void MyClass() {\n"
  pending = responses.map { |r| r[0] == 'pending' ? r[1] : nil }.compact
  failing = responses.map { |r| r[0] == 'fail' ? r[1]["message"] : nil }.compact
  if not pending.empty?
    funcs += "    pending(\"#{pending[0]}\");\n"
  end
  if not failing.empty?
    funcs += "    throw new Some.Foreign.ExceptionType(\"#{failing[0]}\");\n"
  end
  funcs += "}\n";

  funcs
end

def get_details_string(responses)
  responses.each do |response|
    if response.length < 2 then next end
    if response[0] != "success" then next end
    response[1].each do |info|
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
module MyApp;

import cucumber.server;
import Some.Foreign;
import vibe.d;
import std.stdio;

#{funcs}

shared static this() {
    setLogLevel(LogLevel.debugV);
    writeln("Running the Cucumber server");

    runCucumberServer!__MODULE__(#{port}#{details});
}

EOF
  filename = '/tmp/source/MyApp.d'
  _write_file(filename, lines)
  puts "#{filename}:\n#{lines}"

end

def write_exception
  lines = <<-EOF
module Some.Foreign;

class ExceptionType: Exception {
    this(string msg) {
        super(msg);
    }
}
EOF
  _write_file('/tmp/source/Some/Foreign.d', lines);
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
  write_exception
  connect_to_server(port)
end
