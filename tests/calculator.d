module tests.calculator;

import unit_threaded;
import cucumber.match;


private string[] funcCalls;


@Given!(r"^a calculator$")
void giveCalc() {
    funcCalls ~= "given";
}

@When!(r"^the calculator computes PI$")
void whenCalc() {
    funcCalls ~= "when";
}

@Then!(r"^the calculator returns PI$")
void thenCalc() {
    funcCalls ~="then";
}

void testCalculator() {
    funcCalls = [];
    const results = runFeature!__MODULE__(["a calculator",
                                           "the calculator computes PI",
                                           "the calculator returns PI"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 1);
    checkEqual(results.numFailing, 0);
    checkEqual(results.numPending, 0);
    checkEqual(results.numUndefined, 0);
    checkEqual(results.toString(), "1 scenario (1 passed)");
    checkEqual(funcCalls, ["given", "when", "then"]);

}
