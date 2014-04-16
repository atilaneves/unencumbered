module cucumber.match;

import cucumber.ctutils;
import cucumber.reflection;

import std.regex;
import std.conv;
import std.algorithm;
import std.traits;

struct Match(string reg) { }
alias Given = Match;
alias When = Match;
alias Then = Match;
alias And = Match;
alias But = Match;

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

string stripCucumberKeywords(string str) {
    string stripImpl(string str, in string keyword) {
        str = std.string.stripLeft(str);
        if(str.startsWith(keyword)) {
            return std.array.replace(str, keyword, "");
        } else {
            return str;
        }
    }

    foreach(keyword; ["Given", "When", "Then", "And", "But"]) {
        str = stripImpl(str, keyword);
    }

    return std.string.stripLeft(str);
}

auto runFeature(Modules...)(string[] input) {
    foreach(line; input.map!(l => std.string.stripLeft(l))) {

        if(line.startsWith("Feature:")) continue;
        if(line.startsWith("Scenario:")) continue;

        auto func = findMatch!Modules(line);
        if(func is null) {
            import std.stdio;
            writeln("Could not find match for ", line);
        }
        if(func is null) return FeatureResults(1, 0, 0, 0, 1);

        try {
            func();
        } catch(PendingException) {
            return FeatureResults(1, 0, 0, 1);
        } catch(Exception e) {
            import std.stdio;
            writeln("Exception: ", e.msg);
            return FeatureResults(1, 0, 1, 0);
        }
    }
    return FeatureResults(1, 1, 0, 0);
}


void pending(in string msg = "") {
    throw new PendingException(msg);
}
