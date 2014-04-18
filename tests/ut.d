import unit_threaded.runner;
import std.stdio;

int main(string[] args) {
    writeln("\nAutomatically generated file tests/ut.d");
    writeln(`Running unit tests from dirs ["tests"]
`);
    return args.runTests!("tests.reflection", "tests.match", "tests.given_when_then", "tests.keywords",
                          "tests.calculator.feature", "tests.server_match");
}
