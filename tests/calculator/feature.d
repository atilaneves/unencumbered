module tests.calculator.feature;

import tests.calculator.steps;
import tests.calculator.impl;
import cucumber;
import cucumber.reflection;
import unit_threaded;
import std.math;

void testCalculatorSteps() {
    writelnUt("test steps");
    checkNotNull(findMatch!"tests.calculator.steps"("    Given a calculator"));
    findMatch!"tests.calculator.steps"("    When the calculator adds up \"3\", \"4\" and \"5\"")();
}

void testCalculator() {
    const results = runFeature!"tests.calculator.steps"(["Feature: A feature",
                                            "  Scenario: scenario",
                                            "    Given a calculator",
                                            "    When the calculator adds up \"3\", \"4\" and \"5\"",
                                            "    Then the calculator returns \"12\""]);
    checkEqual(calculator.result, 12);
    checkEqual(results.toString, "1 scenario (1 passed)");
}

void testCalculator2() {

    const results = runFeature!"tests.calculator.steps"(["Feature: A feature",
                                           "  Scenario: scenario",
                                           "    Given a calculator",
                                           "    When the calculator adds up 1 and 2",
                                           "    And the calculator adds up 3 and 0.14159265",
                                           "    Then the calculator returns PI",
                                           "    But the calculator does not return 3"]);
    writelnUt("Calculator result: ", calculator.result);
    checkFalse(closeEnough(calculator.result, 3));
}
