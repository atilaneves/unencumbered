module tests.given_when_then;

import unit_threaded;
import cucumber.keywords;
import cucumber.feature;

private string[] funcCalls;

@Given(r"^A situation$")
void given() {
    funcCalls ~= "Given";
}

@When(r"^I do this")
void when() {
    funcCalls ~= "When";
}

@Then(r"^This happens")
void then() {
    funcCalls ~= "Then";
}

@When(r"I do a failing step$")
void failingStep() {
    funcCalls ~= "failingStep";
    throw new Exception("Exception: step failed");
}

void testGivenUndefinedWithNoMapping() {
    funcCalls = [];
    const results = runFeature!__MODULE__(["Non matching string"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 0);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 1);
    shouldEqual(results.toString(), "1 scenario (1 undefined)");
    shouldEqual(funcCalls, []);
}

void testGivenWhenThen() {
    funcCalls = [];
    const results = runFeature!__MODULE__(["Feature: A feature", "  Scenario: A Scenario:",
                                           "    Given A situation",
                                           "    When I do this",
                                           "    Then This happens"]);
    shouldEqual(results.numScenarios, 1);
    shouldEqual(results.numPassing, 1);
    shouldEqual(results.numFailing, 0);
    shouldEqual(results.numPending, 0);
    shouldEqual(results.numUndefined, 0);
    shouldEqual(results.toString(), "1 scenario (1 passed)");
    shouldEqual(funcCalls, ["Given", "When", "Then"]);
}
