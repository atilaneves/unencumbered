module tests.given_when_then;

import unit_threaded;
import cucumber.match;


private string[] funcCalls;

@Given!(r"^A situation$")
void given(in string[]) {
    funcCalls ~= "Given";
}

@When!(r"^I do this")
void when(in string[]) {
    funcCalls ~= "When";
}

@Then!(r"^This happens")
void then(in string[]) {
    funcCalls ~= "Then";
}

@When!(r"I do a failing step$")
void failingStep(in string[]) {
    funcCalls ~= "failingStep";
    throw new Exception("Exception: step failed");
}

void testGivenUndefinedWithNoMapping() {
    funcCalls = [];
    const results = runFeature!__MODULE__(["Non matching string"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 0);
    checkEqual(results.numFailing, 0);
    checkEqual(results.numPending, 0);
    checkEqual(results.numUndefined, 1);
    checkEqual(results.toString(), "1 scenario (1 undefined)");
    checkEqual(funcCalls, []);
}

void testGivenWhenThen() {
    funcCalls = [];
    const results = runFeature!__MODULE__(["Feature: A feature", "  Scenario: A Scenario:",
                                           "    Given A situation",
                                           "    When I do this",
                                           "    Then This happens"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 1);
    checkEqual(results.numFailing, 0);
    checkEqual(results.numPending, 0);
    checkEqual(results.numUndefined, 0);
    checkEqual(results.toString(), "1 scenario (1 passed)");
    checkEqual(funcCalls, ["Given", "When", "Then"]);

}
