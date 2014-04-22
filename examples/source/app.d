import cucumber.server;
import std.stdio;

shared static this() {
    writeln("Running the Example Cucumber server");
    runCucumberServer!"tests.calculator.steps"(54321, Yes.details);
}
