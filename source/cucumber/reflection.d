module cucumber.reflection;

import cucumber.ctutils;
import cucumber.match;
import std.traits;
import std.typetuple;


private enum isMatchStruct(T) = is(T:Match!S, string S);

unittest {
    static assert(isMatchStruct!(Match!""));
}

private enum hasMatchUDA(alias T) = Filter!(isMatchStruct, __traits(getAttributes, T)).length > 0;

private template matchToRegex(T: Match!S, string S) if(isMatchStruct!T) {
    enum matchToRegex = S;
}

enum getRegex(alias T) = matchToRegex!(Filter!(isMatchStruct, __traits(getAttributes, T))[0]);

unittest {
    @Match!(r"^foo reg")
    void foo() {
        static assert(hasMatchUDA!(foo));
        static assert(matchToRegex!(Match!"my regex") == "my regex");
        static assert(getRegex!(foo) == "^foo reg");
    }

    void bar() {
        static assert(!hasMatchUDA!(bar));
    }
}

struct CucumberStep {
    void function() func;
    string regex;
}


/**
 * Finds all steps in all modules. Modules are passed in as strings.
 * Steps are found by using compile-time reflection to register
 * all functions with the Match UDA attached to it and extracting
 * the relevant regex from the Match UDA itself.
 */
auto findSteps(ModuleNames...)() if(allSatisfy!(isSomeString, (typeof(ModuleNames)))) {
    mixin(importModulesString!ModuleNames);
    CucumberStep steps[];
    foreach(mod; ModuleNames) {
        foreach(member; __traits(allMembers, mixin(mod))) {

            enum compiles = __traits(compiles, mixin(member));

            static if(compiles) {

                enum isFunction = isSomeFunction!(mixin(member));
                enum hasMatch = hasMatchUDA!(mixin(member));

                static if(isFunction && hasMatch) {
                    enum reg = getRegex!(mixin(member));
                    mixin(`steps ~= CucumberStep(&` ~ member ~ `, r"` ~ reg ~ `");`);
                    //e.g. steps ~= CucumberStep(&myfunc, r"foobar");
                }
            }
        }
    }

    return steps;
}


/**
 * Finds the match to a step string. Checks all steps and loops
 * over to see which one has a matching regex. Steps are found
 * at compile-time.
 */
void function() findMatch(ModuleNames...)(in string step_str) {
    enum steps = findSteps!ModuleNames;
    foreach(step; steps) {
        import std.regex;
        if(step_str.match(step.regex)) {
            return step.func;
        }
    }
    return null;
}
