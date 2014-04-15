module tests.match;

import unit_threaded;
import cucumber.match;
import std.traits;

private string[] funcCalls;

public:

@Match!(r"^I match a passing step$")
void passingStep1() {
    funcCalls ~= "passingStep1";
}

@Match!(r"^I also match a passing step$")
void passingStep2() {
    funcCalls ~= "passingStep2";
}

@Match!(r"^What about me. I also pass$")
void passingStep3() {
    funcCalls ~= "passingStep3";
}

@Match!(r"I match a failing step$")
void failingStep() {
    funcCalls ~= "failingStep";
    throw new Exception("Exception: step failed");
}

private {
    @Match!(r"Never going to see me")
    void privateStep();
}


void testMatchPassing12() {
    funcCalls = [];
    const results = runFeatures!__MODULE__(["I match a passing step", "I also match a passing step"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 1);
    checkEqual(results.numPending, 0);
    checkEqual(results.numFailing, 0);
    checkEqual(results.toString(), "1 scenario (1 passed)");
    checkEqual(funcCalls, ["passingStep1", "passingStep2"]);
}

void testMatchPassing3() {
    funcCalls = [];
    const results = runFeatures!__MODULE__(["What about me? I also pass"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 1);
    checkEqual(results.numFailing, 0);
    checkEqual(results.numPending, 0);
    checkEqual(results.toString(), "1 scenario (1 passed)");
    checkEqual(funcCalls, ["passingStep3"]);
}

void testMatchNotPassing() {
    funcCalls = [];
    const results = runFeatures!__MODULE__(["I match a failing step"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 0);
    checkEqual(results.numFailing, 1);
    checkEqual(results.numPending, 0);
    checkEqual(results.toString(), "1 scenario (1 failed)");
    checkEqual(funcCalls, ["failingStep"]);
}


void testNoMatch() {
    funcCalls = [];
    const results = runFeatures!__MODULE__(["totally invented string"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 0);
    checkEqual(results.numFailing, 1);
    checkEqual(results.numPending, 0);
    checkEqual(results.toString(), "1 scenario (1 failed)");
    checkEqual(funcCalls, []);
}

@Match!(r"Gotta match pending")
void pendingStep() {
    pending();
}

void testPending() {
    funcCalls = [];
    const results = runFeatures!__MODULE__(["Gotta match pending"]);
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 0);
    checkEqual(results.numFailing, 0);
    checkEqual(results.numPending, 1);
    checkEqual(results.toString(), "1 scenario (1 pending)");
    checkEqual(funcCalls, []);
}
