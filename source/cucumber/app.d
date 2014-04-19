module cucumber.app;

import cucumber.server;
import vibe.d;

shared static this() {
    debug {
        setLogLevel(LogLevel.debugV);
    }
    runCucumberServer!__MODULE__(54321);
}
