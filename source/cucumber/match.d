module cucumber.match;

import std.regex;
public import std.typecons;

private int numScenarios;
private int numPassing;
private int numPending;
private string[] steps;

void reset() {
    numScenarios = numPassing = numPending = 0;
}

auto getNumScenarios() {
    return numScenarios;
}

auto getNumPassed() {
    return numPending ? 0 : 1;
}

auto getNumPending() {
    return numPending;
}

void Match(string step)(Flag!"Pending" pending = No.Pending) {
    if(!numScenarios) numScenarios++;
    pending ? numPending++ : numPassing++;
    steps ~= step;
}
