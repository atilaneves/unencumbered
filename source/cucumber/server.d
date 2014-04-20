module cucumber.server;

public import cucumber.keywords;
public import cucumber.feature;

import cucumber.reflection;
import cucumber.feature: PendingException;
import vibe.d;
import std.stdio;
import std.conv;
public import std.typecons: Flag, Yes, No;

alias DetailsFlag = Flag!"details";
MatchResult[int] gMatches;

void runCucumberServer(ModuleNames...)(ushort port, DetailsFlag details = No.details) {
    debug writeln("Running the Cucumber server on port ", port, " details ", details);
    listenTCP(54321, (tcpConnection) { accept!ModuleNames(tcpConnection, details); });
}


private void accept(ModuleNames...)(TCPConnection tcpConnection, DetailsFlag details) {
    debug writeln("Accepting a connection");
    while(tcpConnection.connected) {
        auto bytes = tcpConnection.readLine(size_t.max, "\n");
        handleTcpRequest!ModuleNames(tcpConnection, (cast(string)bytes).strip(), details);
    }

    if(tcpConnection.connected) tcpConnection.close();
}

private void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

private void handleTcpRequest(ModuleNames...)(TCPConnection tcpConnection, in string request,
                                              Flag!"details" details) {
    const reply = handleRequest!ModuleNames(request, details);
    debug writeln("Reply: ", reply);
    tcpConnection.send(reply);
}

string handleRequest(ModuleNames...)(string request, Flag!"details" details = No.details) {
    debug writeln("Request: ", request);
    const fail = `["fail"]`;

    try {
        const json = parseJson(request);
        const command = json[0].get!string;
        if(command == "begin_scenario") return `["success"]`;
        if(command == "end_scenario") return `["success"]`;
        if(command != "step_matches" && command != "invoke") return fail;

        if(command == "step_matches") {
            const nameToMatch = json[1]["name_to_match"].get!string;
            auto func = findMatch!ModuleNames(nameToMatch);
            if(!func) return `["success",[]]`;
            gMatches[func.id] = func;

            auto infoElem = Json.emptyObject;
            infoElem.id = func.id.to!string;
            infoElem.args = Json.emptyArray;

            if(details) {
                infoElem.regexp = func.regex;
                infoElem.source = func.source;
            }

            auto info = Json.emptyArray;
            info ~= infoElem;

            return `["success",` ~ info.toString ~ `]`;
        } else if(command == "invoke") {
            writeln("invoke");
            const invokeArgs = json[1];
            const id = invokeArgs.id.to!int;
            if(id !in gMatches) throw new Exception(text("Could not find match for id ", id));
            try {
                gMatches[id]();
            } catch(PendingException ex) {
                return `["pending", "` ~ ex.msg ~ `"]`;
            } catch(Throwable ex) {
                return `["fail",{"message":"` ~ ex.msg ~ `", "exception": "` ~ ex.classinfo.name ~ `"}]`;
            }
            return `["success"]`;
        }
    } catch(Throwable ex) {
        stderr.writeln("Error processing request: ", request);
        stderr.writeln("Exception: ", ex.toString().sanitize());
        return fail;
    }

    return fail;
}
