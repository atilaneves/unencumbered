module tests.calculator.steps;

import cucumber.keywords;
import unit_threaded;
import tests.calculator.impl;
import std.conv;
import std.math;
import std.stdio;


@Given(r"^a calculator$")
void initCalculator() {
    calculator = Calculator();
}

@When(r"^the calculator computes PI$")
void calculatorComputesPi() {
    calculator.computePi();
}

@Then(r"^the calculator returns PI$")
void calculatorReturns() {
    debug writeln("returns pi");
    shouldBeTrue(closeEnough(calculator.result, PI));
}

@When(`^the calculator adds up "?([0-9.]+)"? and "?([0-9.]+)"?$`)
void whenAddsUp(in double a, in double b) {
    debug writeln("adding ", a, " to ", b);
    calculator.add(a, b);
}

@And(r"^the calculator adds up ([0-9.]+) and ([0-9.]+)$")
void andAddsUp(in double a, in double b) {
    debug writeln("andAddsUp adding up ", a, " to ", b);
    calculator.add(a, b);
}

@When(`the calculator adds up "([0-9.]+)", "([0-9.]+)" and "([0-9.]+)"`)
void whenAdds3(in double a, in double b, in double c) {
    debug writeln("whenAdds3 adding up ", a, ", ", b, " to ", c);
    calculator.add(a, b, c);
}

@But(r"^the calculator does not return 3$")
void butDoesNot() {
    shouldBeFalse(closeEnough(calculator.result, 3));
}

@Then(`^the calculator returns "(.+)"`)
void thenReturnsPi(in string a) {
    debug writeln("returns capture");
    shouldBeTrue(closeEnough(calculator.result, a.to!double));
}
