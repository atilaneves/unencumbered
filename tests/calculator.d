module tests.calculator;

import cucumber.keywords;
import cucumber.feature;
import unit_threaded;
import std.conv;
import std.math;

import cucumber.reflection;

struct Calculator {
    double result;

    void add(T...)(T args) {
        result = 0;
        foreach(a; args) result += a;
        writelnUt(" result is now ", result);
    }

    void computePi() {
        result = PI;
    }
}

private Calculator calculator;

bool closeEnough(T, U)(T a, U b) {
    return abs(a - b) < 1e-6;
}


@Given!(r"^a calculator$")
void initCalculator(in string[]) {
    writelnUt("Given a calculator");
    calculator = Calculator();
}

@When!(r"^the calculator computes PI$")
void calculatorComputesPi(in string[]) {
    calculator.computePi();
}

@Then!(r"^the calculator returns PI$")
void calculatorReturns(in string[]) {
    checkTrue(closeEnough(calculator.result, PI));
}

@When!(r"^the calculator adds up ([0-9.]+) and ([0-9.]+)$")
void whenAddsUp(in string[] captures) {
    calculator.add(captures[1].to!double, captures[2].to!double);
}

@And!(r"^the calculator adds up ([0-9.]+) and ([0-9.]+)$")
void andAddsUp(in string[] captures) {
    writelnUt("and adds up ", captures[1], " to ", captures[2]);
    calculator.add(captures[1].to!double, captures[2].to!double);
}

@But!(r"^the calculator does not return 3$")
void butDoesNot(in string[]) {
    checkFalse(closeEnough(calculator.result, 3));
}

@Then!(`^the calculator returns "(.+)"`)
void thenReturnsPi(in string[] captures) {
    writelnUt("calculator returning");
    checkTrue(closeEnough(calculator.result, captures[1].to!double));
}

@When!`the calculator adds up "([0-9.]+)", "([0-9.]+)" and "([0-9.]+)"`
void addsUp3Numbers(in string[] captures) {
    writelnUt("adds up 3 numbers");
    calculator.add(captures[1].to!double, captures[2].to!double, captures[3].to!double);
}

void testCalculatorSteps() {
    writelnUt("test steps");
    checkNotNull(findMatch!__MODULE__("    Given a calculator"));
    findMatch!__MODULE__("    When the calculator adds up \"3\", \"4\" and \"5\"")();
}

void testCalculator() {
    const results = runFeature!__MODULE__(["Feature: A feature",
                                           "  Scenario: scenario",
                                           "    Given a calculator",
                                           "    When the calculator adds up \"3\", \"4\" and \"5\"",
                                           "    Then the calculator returns \"12\""]);
    checkEqual(calculator.result, 12);
    checkEqual(results.toString, "1 scenario (1 passed)");
}

void testCalculator2() {
    const results = runFeature!__MODULE__(["Feature: A feature",
                                           "  Scenario: scenario",
                                           "    Given a calculator",
                                           "    When the calculator adds up 1 and 2",
                                           "    And the calculator adds up 3 and 0.14159265",
                                           "    Then the calculator returns PI",
                                           "    But the calculator does not return 3"]);
    writelnUt("Calculator result: ", calculator.result);
    checkFalse(closeEnough(calculator.result, 3));
}
