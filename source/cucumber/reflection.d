module cucumber.reflection;

import cucumber.ctutils;
import cucumber.match;
import std.traits;
import std.typetuple;
import std.regex;


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
    this(void function() func, Regex!char regex) {
        this.func = func;
        this.regex = regex;
    }

    this(void function() func, in string reg) {
        this.func = func;
        this.regex = std.regex.regex(reg);
    }

    void function() func;
    Regex!char regex;
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
        if(step_str.match(step.regex)) {
            return step.func;
        }
    }
    return null;
}

/**
 * Counts the number of parentheses pairs in a string known
 * at compile-time
 */
int countParenPairs(string reg)() {
    int intCount(in string haystack, in string needle) {
        import std.algorithm: count;
        return cast(int)haystack.count(needle);
    }

    return (intCount(reg, "(") + intCount(reg, ")") -
            intCount(reg, r"\(") - intCount(reg, r"\)")) / 2;
}

unittest {
    static assert(countParenPairs!r"" == 0);
    static assert(countParenPairs!r"foo" == 0);
    static assert(countParenPairs!r"(" == 0);
    static assert(countParenPairs!r"\(\)" == 0);
    static assert(countParenPairs!r"()" == 1);
    static assert(countParenPairs!r"()\(\)" == 1);
    static assert(countParenPairs!r"\(\)()" == 1);
    static assert(countParenPairs!r"()\(\)()" == 2);
    static assert(countParenPairs!r"(foo).+\(oh noes\).+(bar)" == 2);
}
