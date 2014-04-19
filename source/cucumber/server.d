module cucumber.server;

import cucumber.reflection;
import vibe.d;
import std.stdio;


void runCucumberServer(ModuleNames...)(ushort port) {
    debug writeln("Running the Cucumber server");
    listenTCP_s(54321, &accept!ModuleNames);
}


private void accept(ModuleNames...)(TCPConnection tcpConnection) {
    debug writeln("Accepting a connection");
    while(tcpConnection.connected) {
        auto bytes = tcpConnection.readLine(size_t.max, "\n");
        //auto bytes = new ubyte[tcpConnection.leastSize];
        //tcpConnection.read(bytes);

        handle!ModuleNames(tcpConnection, (cast(string)bytes).strip());
    }

    if(tcpConnection.connected) tcpConnection.close();
}

private void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

private void handle(ModuleNames...)(TCPConnection tcpConnection, in string request) {
    debug writeln("\nRequest:\n", request, "\n");
    const reply = handleRequest!ModuleNames(request);
    debug writeln("\nReply:\n", reply, "\n");
    tcpConnection.send(reply);
}

string handleRequest(ModuleNames...)(string request) {
    const fail = `["fail"]`;

    try {
        const json = parseJson(request);
        if(json[0].get!string != "step_matches") return fail;

        auto func = findMatch!ModuleNames(json[1]["name_to_match"].get!string);
        if(!func) return `["success",[]]`;

        auto infoElem = Json.emptyObject;
        infoElem.id = func.id.to!string;
        infoElem.args = Json.emptyArray;

        auto info = Json.emptyArray;
        info ~= infoElem;

        return `["success",` ~ info.toString ~ `]`;
    } catch(Throwable ex) {
        stderr.writeln("Error processing request: ", request);
        stderr.writeln("Exception: ", ex.toString().sanitize());
        return fail;
    }
}
