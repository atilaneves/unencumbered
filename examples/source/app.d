import cucumber.server;
import vibe.d;
import std.stdio;

shared static this() {
    setLogLevel(LogLevel.debugV);
    writeln("Running the Example Cucumber server");

    runCucumberServer!"calculator_steps"(54321, Yes.details);
}
