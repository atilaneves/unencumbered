module cucumber.reflection;

import cucumber.ctutils;
import cucumber.match;
import std.traits;
import std.typetuple;


private enum isMatchStruct(T) = is(T:Match!S, string S);
static assert(isMatchStruct!(Match!""));

private enum hasMatchUDA(alias T) = Filter!(isMatchStruct, __traits(getAttributes, T)).length > 0;
private template matchToRegex(T: Match!S, string S) if(isMatchStruct!T) {
    enum matchToRegex = S;
}

enum getRegex(alias T) = matchToRegex!(Filter!(isMatchStruct, __traits(getAttributes, T))[0]);

@Match!(r"^foo reg")
private void foo() {
    static assert(hasMatchUDA!(foo));
    static assert(matchToRegex!(Match!"my regex") == "my regex");
    static assert(getRegex!(foo) == "^foo reg");
}

private void bar() {
    static assert(!hasMatchUDA!(bar));
}

struct CucumberStep {
    void function() func;
    string regex;
}

auto findSteps(ModuleNames...)() if(allSatisfy!(isSomeString, (typeof(ModuleNames)))) {
    mixin("import " ~ modulesString!ModuleNames ~ ";");
    CucumberStep steps[];
    foreach(mod; ModuleNames) {
        foreach(member; __traits(allMembers, mixin(mod))) {
            static if(__traits(compiles, mixin(member)) && isSomeFunction!(mixin(member)) &&
                      hasMatchUDA!(mixin(member))) {
                enum reg = getRegex!(mixin(member));
                mixin(`steps ~= CucumberStep(&` ~ member ~ `, r"` ~ reg ~ `");`);
            }
        }
    }
    return steps;
}

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
