module tests.calculator.steps;

import cucumber;
import unit_threaded;
import tests.calculator.impl;
import std.conv;
import std.math;
import std.stdio;


@Given!(r"^a calculator$")
void initCalculator(in string[]) {
    calculator = Calculator();
}

@When!(r"^the calculator computes PI$")
void calculatorComputesPi(in string[]) {
    calculator.computePi();
}

@Then!(r"^the calculator returns PI$")
void calculatorReturns(in string[]) {
    writeln("returns pi");
    checkTrue(closeEnough(calculator.result, PI));
}

@When!(`^the calculator adds up "?([0-9.]+)"? and "?([0-9.]+)"?$`)
void whenAddsUp(in string[] captures) {
    writeln("adding ", captures[1], " to ", captures[2]);
    calculator.add(captures[1].to!double, captures[2].to!double);
}

@And!(r"^the calculator adds up ([0-9.]+) and ([0-9.]+)$")
void andAddsUp(in string[] captures) {
    writeln("and adds up ", captures[1], " to ", captures[2]);
    calculator.add(captures[1].to!double, captures[2].to!double);
}

@When!(`the calculator adds up "([0-9.]+)", "([0-9.]+)" and "([0-9.]+)"`)
void whenAdds3(in string[] captures) {
    writeln("and adds up ", captures[1], ", ", captures[2], " to ", captures[3]);
    calculator.add(captures[1].to!double, captures[2].to!double, captures[3].to!double);
}

@But!(r"^the calculator does not return 3$")
void butDoesNot(in string[]) {
    checkFalse(closeEnough(calculator.result, 3));
}

@Then!(`^the calculator returns "(.+)"`)
void thenReturnsPi(in string[] captures) {
    writeln("returns capture");
    checkTrue(closeEnough(calculator.result, captures[1].to!double));
}
