module cucumber.server;

import vibe.d;
import std.stdio;


void runCucumberServer(ModuleNames...)(ushort port) {
    listenTCP_s(54321, &accept!ModuleNames);
}


private void accept(ModuleNames...)(TCPConnection tcpConnection) {
    while(tcpConnection.connected) {
        auto bytes = tcpConnection.readLine(size_t.max, "\n");
        handle(tcpConnection, (cast(string)bytes).strip());
    }

    if(tcpConnection.connected) tcpConnection.close();
}

private void send(ModuleNames...)(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

private void handle(ModuleNames...)(TCPConnection tcpConnection, in string request) {
    debug writeln("\nRequest:\n", request, "\n");
    if(request == `["begin_scenario",{"tags":["wire"]}]`) tcpConnection.send(`["success"]`);
    else {
        debug writeln("oops");
        tcpConnection.send(`["success",[]]`);
    }
}

string handleRequest(ModuleNames...)(string request) {
    debug writeln("handleRequest for ", request);
    const fail = `["fail"]`;
    try {
        const json = parseJson(request);
        debug writeln("constructed json: ", json);
        if(json[0].get!string != "step_matches") return fail;
        return `["success",[]]`;
    } catch(Exception ex) {
        stderr.writeln("Error processing request: ", request);
        stderr.writeln("Exception: ", ex);
        return fail;
    }
}
