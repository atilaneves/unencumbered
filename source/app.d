import vibe.d;
import std.stdio;
import core.time;


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
            debug writeln("\nLine:\n", cast(string)bytes, "\n");
        }
    });

    rtask.join();

    if(tcpConnection.connected) tcpConnection.close();
}
