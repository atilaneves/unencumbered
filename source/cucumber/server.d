module cucumber.server;

import cucumber.reflection;
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
    tcpConnection.send(handleRequest!ModuleNames(request));
}

string handleRequest(ModuleNames...)(string request) {
    debug writeln("handleRequest for ", request);
    const fail = `["fail"]`;

    try {
        const json = parseJson(request);
        if(json[0].get!string != "step_matches") return fail;

        auto func = findMatch!ModuleNames(json[1]["name_to_match"].get!string);
        if(!func) return `["success",[]]`;

        auto reply = Json.emptyArray;
        reply ~= "success";
        writeln("reply: ", reply);

        auto info = Json.emptyObject;
        info.id = func.id.to!string;
        info.args = Json.emptyArray;

        reply ~= info;

        return reply.toString();
    } catch(Throwable ex) {
        stderr.writeln("Error processing request: ", request);
        stderr.writeln("Exception: ", ex.toString().sanitize());
        return fail;
    }
}
