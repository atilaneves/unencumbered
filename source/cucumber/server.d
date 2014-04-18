module cucumber.server;

import vibe.d;
import std.stdio;


void runCucumberServer(ModuleNames...)(ushort port) {
    listenTCP_s(54321, &accept);
}


private void accept(TCPConnection tcpConnection) {
    while(tcpConnection.connected) {
        auto bytes = tcpConnection.readLine(size_t.max, "\n");
        handle(tcpConnection, (cast(string)bytes).strip());
    }

    if(tcpConnection.connected) tcpConnection.close();
}

private void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

private void handle(TCPConnection tcpConnection, in string request) {
    debug writeln("\nRequest:\n", request, "\n");
    if(request == `["begin_scenario",{"tags":["wire"]}]`) tcpConnection.send(`["success"]`);
    else {
        debug writeln("oops");
        tcpConnection.send(`["success",[]]`);
    }
}

string handleRequest(in string request) {
    return(`["fail"]`);
}
