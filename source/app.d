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
            // auto bytes = new ubyte[tcpConnection.leastSize];
            // tcpConnection.read(bytes);
            auto bytes = tcpConnection.readLine(size_t.max, "\n");
            debug writeln("Read ", bytes.length, " bytes");
            handle(tcpConnection, (cast(string)bytes).strip());
        }
    });

    rtask.join();

    if(tcpConnection.connected) tcpConnection.close();
}

void send(TCPConnection tcpConnection, in string str) {
    tcpConnection.write(str ~ "\n"); //I don't know why writeln doesn't work
}

void handle(TCPConnection tcpConnection, in string request) {
    tcpConnection.send(`["success",[]]`);
}
