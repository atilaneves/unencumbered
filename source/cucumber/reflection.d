module cucumber.reflection;

import cucumber.ctutils;
import cucumber.keywords;
import std.traits;
import std.typetuple;
import std.regex;
import std.conv;


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

alias CucumberStepFunction = void function(in string[] = []);

struct CucumberStep {
    this(CucumberStepFunction func, Regex!char reg) {
        this.func = func;
        this.regex = reg;
    }

    this(CucumberStepFunction func, in string reg) {
        this.func = func;
        this.regex = std.regex.regex(reg);
    }

    CucumberStepFunction func;
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
                    enum reg = rawStringMixin(getRegex!(mixin(member)));

                    enum funcArity = arity!(mixin(member));
                    enum numCaptures = countParenPairs!reg;
                    static assert(funcArity == numCaptures,
                                  text("Arity of ", member, " (", funcArity, ")",
                                       " does not match the number of capturing parens (",
                                       numCaptures, ") in ", getRegex!(mixin(member))));

                    //e.g. funcCall would be "myfunc(captures[0], captures[1]);"
                    enum funcCall = member ~ argsStringWithParens!(reg, mixin(member)) ~ ";";

                    //e.g. lambda would be "(captures) { myfunc(captures[0]); }"
                    enum lambda = "(captures) { " ~ funcCall ~ " }";

                    //e.g. steps ~= CucumberStep((in string[] cs) { myfunc(); }, r"foobar");
                    enum mixinStr = `steps ~= CucumberStep(` ~ lambda ~ `, ` ~ reg ~ `);`;

                    mixin(mixinStr);
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
auto findMatch(ModuleNames...)(string step_str) {
    step_str = stripCucumberKeywords(step_str);
    enum steps = findSteps!ModuleNames;
    foreach(step; steps) {
        auto m = step_str.match(step.regex);
        if(m) {
            import std.array;
            return () { step.func(m.captures.array); };
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

/**
 * Returns an array of string mixins to convert each type
 * from a string
 */
auto conversionsFromString(Types...)() {
    string[] convs;
    foreach(T; Types) {
        static if(isSomeString!T) {
            convs ~= "";
        } else {
            convs ~= ".to!" ~ Unqual!T.stringof;
        }
    }
    return convs;
}

unittest {
    static assert(conversionsFromString!(int, string) == [".to!int", ""]);
    static assert(conversionsFromString!(string, double) == ["", ".to!double"]);
}

/**
 * Comma separated argument list for calls to variadic functions
 * associated with regexen. Meant to be used with mixin to
 * generate code.
 */
string argsString(string reg, alias func)() {
    enum convs = conversionsFromString!(ParameterTypeTuple!func);
    enum numCaptures = countParenPairs!reg;
    static assert(convs.length == numCaptures,
                  text("Wrong length for ", convs, ", should be ", numCaptures));

    string[] args;
    foreach(i; 0 .. numCaptures) {
        args ~= "captures[" ~ (i + 1).to!string ~ "]" ~ convs[i];
    }

    import std.array;
    return args.join(", ");
}

string argsStringWithParens(string reg, alias func)() {
    return "(" ~ argsString!(reg, func) ~ ")";
}

unittest {
    void func() {}
    static assert(argsString!(r"", func) == "");

    void func_is(int, string) {}
    static assert(argsString!(r"(foo)...(bar)", func_is) == "captures[1].to!int, captures[2]");

    void func_cis(in int, in string) {}
    static assert(argsString!(r"(foo)...(bar)", func_cis) == "captures[1].to!int, captures[2]");

    void func_si(string, int) {}
    static assert(argsString!(r"(foo)...(bar)", func_si) == "captures[1], captures[2].to!int");

    void func_dd(double, double) {}
    static assert(argsString!(r"(foo)...(bar)", func_dd) == "captures[1].to!double, captures[2].to!double");
}

/**
 * This function is necessary due to the extreme "metaness" of
 * this project. It returns a string that is meant to be consumed
 * by mixin to generate code. Since the strings being fed to
 * the system at compile-time are generally going to be
 * "raw" strings, they'll either be r"" or `` style D strings.
 * If the regex requires the '"' character they'll use ``, and
 * vice-versa. When generating code, I opted for r"" strings.
 * This would cause a compilation error if the regex has the
 * quote character in it. So this function returns an escaped
 * version that can be safely used.
 */
string rawStringMixin(in string str) {
    import std.array;
    return "r\"" ~ str.replace(`"`, "\" ~ `\"` ~ r\"") ~ "\"";
}

unittest {
    static assert(rawStringMixin(`Sharks with "lasers" yo.`) ==
                  "r\"Sharks with \" ~ `\"` ~ r\"lasers\" ~ `\"` ~ r\" yo.\"");
    static assert(rawStringMixin(`foo bar baz`) == "r\"foo bar baz\"");
}
