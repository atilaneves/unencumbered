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
    int numPending;
    int numUndefined;

    string toString() const pure {
        assert(numPassing ^ numFailing ^ numPending ^ numUndefined,
               text(numPassing, numFailing, numPending, numUndefined));
        const suffix = numFailing ? text(numFailing, " failed)") :
                       numPending ? text(numPending, " pending)") :
                       numUndefined ? text(numUndefined, " undefined)") :
                       text(numPassing, " passed)");
        return "1 scenario (" ~ suffix;
    }
}

class PendingException: Exception {
    this(string msg) { super(msg); }
}

auto runFeatures(Modules...)(in string[] input) {
    foreach(line; input) {
        auto func = findMatch!Modules(line);
        if(func is null) return FeatureResults(1, 0, 0, 0, 1);
        try {
            func();
        } catch(PendingException) {
            return FeatureResults(1, 0, 0, 1);
        } catch(Exception) {
            return FeatureResults(1, 0, 1, 0);
        }
    }
    return FeatureResults(1, 1, 0, 0);
}


void pending(in string msg = "") {
    throw new PendingException(msg);
}
