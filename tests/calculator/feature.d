module tests.calculator.feature;

import tests.calculator.steps;
import tests.calculator.impl;
import cucumber;
import cucumber.reflection;
import unit_threaded;
import std.math;

void testCalculatorSteps() {
    const givenStep = "    Given a calculator";
    writelnUt("Checking the step \"", givenStep, "\" is not null");
    shouldBeTrue(cast(bool)findMatch!"tests.calculator.steps"(givenStep));

    const whenStep = "    When the calculator adds up \"3\", \"4\" and \"5\"";
    writelnUt(`Calling the step "`, whenStep, `"`);
    findMatch!"tests.calculator.steps"(whenStep)();
}

void testCalculator() {
    const results = runFeature!"tests.calculator.steps"(["Feature: A feature",
                                            "  Scenario: scenario",
                                            "    Given a calculator",
                                            "    When the calculator adds up \"3\", \"4\" and \"5\"",
                                            "    Then the calculator returns \"12\""]);
    shouldEqual(calculator.result, 12);
    shouldEqual(results.toString, "1 scenario (1 passed)");
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
    shouldBeFalse(closeEnough(calculator.result, 3));
}
