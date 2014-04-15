module tests.match;

import unit_threaded;
import cucumber.match;
import std.traits;


@Match!(r"I add 4 and 5")
void testFunc1() {
}

void testMatchPassing() {
    enum myModule = moduleName!testFunc1;
    const results = runFeatures!myModule("I add 4 and 5");
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 1);
    checkEqual(results.numFailing, 0);
    checkEqual(results.toString(), "1 scenario (1 passed)");
}

void testMatchNotPassing() {
    enum myModule = moduleName!testFunc1;
    const results = runFeatures!myModule("asda is better than tesco!");
    checkEqual(results.numScenarios, 1);
    checkEqual(results.numPassing, 0);
    checkEqual(results.numFailing, 1);
    checkEqual(results.toString(), "1 scenario (1 failing)");
}
