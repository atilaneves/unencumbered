module cucumber.app;

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
