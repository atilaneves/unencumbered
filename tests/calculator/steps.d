module tests.calculator.steps;

import cucumber;
import unit_threaded;
import tests.calculator.impl;
import std.conv;
import std.math;
import std.stdio;


@Given!(r"^a calculator$")
void initCalculator() {
    calculator = Calculator();
}

@When!(r"^the calculator computes PI$")
void calculatorComputesPi() {
    calculator.computePi();
}

@Then!(r"^the calculator returns PI$")
void calculatorReturns() {
    writeln("returns pi");
    checkTrue(closeEnough(calculator.result, PI));
}

@When!(`^the calculator adds up "?([0-9.]+)"? and "?([0-9.]+)"?$`)
void whenAddsUp(in string a, in string b) {
    writeln("adding ", a, " to ", b);
    calculator.add(a.to!double, b.to!double);
}

@And!(r"^the calculator adds up ([0-9.]+) and ([0-9.]+)$")
void andAddsUp(in string a, in string b) {
    writeln("and adds up ", a, " to ", b);
    calculator.add(a.to!double, b.to!double);
}

@When!(`the calculator adds up "([0-9.]+)", "([0-9.]+)" and "([0-9.]+)"`)
void whenAdds3(in string a, in string b, in string c) {
    writeln("and adds up ", a, ", ", b, " to ", c);
    calculator.add(a.to!double, b.to!double, c.to!double);
}

@But!(r"^the calculator does not return 3$")
void butDoesNot() {
    checkFalse(closeEnough(calculator.result, 3));
}

@Then!(`^the calculator returns "(.+)"`)
void thenReturnsPi(in string a, in string) {
    writeln("returns capture");
    checkTrue(closeEnough(calculator.result, a.to!double));
}
