import vibe.d;
import std.stdio;
import std.string;

shared static this() {
    debug {
        setLogLevel(LogLevel.debugV);
    }
    listenTCP_s(54321, &accept);
}

void accept(TCPConnection tcpConnection) {
    auto rtask = runTask({
        while(tcpConnection.connected) {
            auto bytes = new ubyte[tcpConnection.leastSize];
            tcpConnection.read(bytes);
            debug writeln("Read ", bytes.length, " bytes");
            handle(tcpConnection, (cast(string)bytes).strip());
        }
    });

    rtask.join();

    if(tcpConnection.connected) tcpConnection.close();
}

void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\r\n");
}

void handle(TCPConnection tcpConnection, in string request) {
    debug writeln("request is length ", request.length);
    debug writeln("\nLine:\n", request, "\n");
    if(request == `["step_matches",{"name_to_match":"we're all wired"}]`) {
        debug writeln("1");
        tcpConnection.send(`["success",[]]`);
    } else if(request == `["step_matches",{"name_to_match":"we're all:"}]`) {
        debug writeln("2");
        tcpConnection.write(`["success",[{"id":"1", "args":[{"val":"we're", "pos":0}]}]]` ~ "\r\n");
    } else if(request == `["begin_scenario"]`) {
        debug writeln("3");
        tcpConnection.send(`["success"]`);
    } else if(request == `["invoke",{"id":"1","args":["we're",[["wired"],["high"],["happy"]]]}]`) {
        debug writeln("4");
        tcpConnection.send(`["success"]`);
    } else if(request == `["end_scenario"]`) {
        debug writeln("5");
        tcpConnection.send(`["success"]`);
    } else  {
        debug writeln("oops");
        tcpConnection.send(`["",[]]`);
    }
}
