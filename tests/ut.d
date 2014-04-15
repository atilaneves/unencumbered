import unit_threaded.runner;
import std.stdio;

int main(string[] args) {
    writeln("\nAutomatically generated file tests/ut.d");
    writeln(`Running unit tests from dirs ["tests"]
`);
    return runTests!("tests.reflection", "tests.match")(args);
}
