module cucumber.feature;

import cucumber.ctutils;
import cucumber.reflection;

import std.regex;
import std.conv;
import std.algorithm;
import std.traits;
import std.encoding: sanitize;

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


auto runFeature(Modules...)(string[] input) {
    foreach(line; input.map!(l => std.string.stripLeft(l))) {

        if(line.startsWith("Feature:")) continue;
        if(line.startsWith("Scenario:")) continue;

        auto func = findMatch!Modules(line);
        if(!func) {
            import std.stdio;
            stderr.writeln("Could not find match for ", line);
        }
        if(!func) return FeatureResults(1, 0, 0, 0, 1);

        try {
            func();
        } catch(PendingException) {
            return FeatureResults(1, 0, 0, 1);
        } catch(Throwable e) {
            import std.stdio;
            stderr.writeln("Exception: ", e.msg.sanitize);
            return FeatureResults(1, 0, 1, 0);
        }
    }
    return FeatureResults(1, 1, 0, 0);
}


void pending(in string msg = "") {
    throw new PendingException(msg);
}
