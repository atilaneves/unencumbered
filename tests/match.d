module tests.match;

import unit_threaded;
import cucumber.keywords;
import cucumber.feature;

package string[] matchFuncCalls;

@Match(r"^I match a passing step$")
void passingStep1() {
    matchFuncCalls ~= "passingStep1";
}

@Match(r"^I also match a passing step$")
void passingStep2() {
    matchFuncCalls ~= "passingStep2";
}

@Match(r"^What about me. I also pass$")
void passingStep3() {
    matchFuncCalls ~= "passingStep3";
}

@Match(r"I match a failing step$")
void failingStep() {
    matchFuncCalls ~= "failingStep";
    throw new Exception("Exception: step failed");
}

private {
    @Match(r"Never going to see me")
    void privateStep();
}


void testMatchPassing12() {
    matchFuncCalls = [];
    const results = runFeature!__MODULE__(["Feature: A feature", "  Scenario: A Scenario:",
                                           "I match a passing step", "I also match a passing step"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 1);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 0);
    shouldEqual(results.toString(), "1 scenario (1 passed)");
    shouldEqual(matchFuncCalls, ["passingStep1", "passingStep2"]);
}

void testMatchPassing3() {
    matchFuncCalls = [];
    const results = runFeature!__MODULE__(["What about me? I also pass"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 1);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 0);
    shouldEqual(results.toString(), "1 scenario (1 passed)");
    shouldEqual(matchFuncCalls, ["passingStep3"]);
}

void testMatchNotPassing() {
    matchFuncCalls = [];
    const results = runFeature!__MODULE__(["I match a failing step"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 0);
    shouldEqual(results.numFailing, 1);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 0);
    shouldEqual(results.toString(), "1 scenario (1 failed)");
    shouldEqual(matchFuncCalls, ["failingStep"]);
}


void testUndefinedWithWrongString() {
    matchFuncCalls = [];
    const results = runFeature!__MODULE__(["totally invented string"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 0);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 1);
    shouldEqual(results.toString(), "1 scenario (1 undefined)");
    shouldEqual(matchFuncCalls, []);
}


@Match(r"Gotta match pending")
void pendingStep() {
    pending();
}

void testPending() {
    matchFuncCalls = [];
    const results = runFeature!__MODULE__(["Gotta match pending"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 0);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 1);
    shouldEqual(results.toString(), "1 scenario (1 pending)");
    shouldEqual(matchFuncCalls, []);
}
