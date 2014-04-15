module cucumber.match;

import cucumber.ctutils;
import cucumber.reflection;

import std.regex;
import std.conv;
import std.algorithm;
import std.traits;

struct Match(string reg) { }

struct FeatureResults {
    int numScenarios;
    int numPassing;
    int numFailing;

    string toString() const pure {
        const suffix = numFailing ? text(numFailing, " failed)") : text(numPassing, " passed)");
        return "1 scenario (" ~ suffix;
    }
}

auto runFeatures(Modules...)(in string[] input) {
    foreach(line; input) {
        auto func = findMatch!Modules(line);
        if(func is null) return FeatureResults(1, 0, 1);
        try {
            func();
        } catch(Exception) {
            return FeatureResults(1, 0, 1);
        }
    }
    return FeatureResults(1, 1, 0);
}
