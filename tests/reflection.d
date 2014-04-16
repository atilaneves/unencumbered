module tests.reflection;

import unit_threaded;
import cucumber.keywords;
import cucumber.reflection;
import std.regex;
import std.algorithm;
import std.array;

private string[] reflectionFuncCalls;

@Match!(r"^I match step1")
void step1(in string[]) {
    reflectionFuncCalls ~= "step1";
}

@Match!(r"^I think I match step2")
void step2(in string[]) {
    reflectionFuncCalls ~= "step2";
}

@Match!(r"^Ooh, step3$")
void step3(in string[]) {
    reflectionFuncCalls ~= "step3";
}

private {
    @Match!(r"Never going to see me")
    void privateStep() {
        reflectionFuncCalls ~= "privateStep";
    }
}

void testFindMySteps() {
    reflectionFuncCalls = [];

    auto steps = findSteps!__MODULE__;
    auto regexen = [r"^I match step1", r"^I think I match step2", r"^Ooh, step3$"];

    checkEqual(steps.map!(a => a.regex).array,
               regexen.map!(a => std.regex.regex(a)).array);

    steps[0].func();
    checkEqual(reflectionFuncCalls, ["step1"]);

    steps[1].func();
    checkEqual(reflectionFuncCalls, ["step1", "step2"]);

    steps[2].func();
    checkEqual(reflectionFuncCalls, ["step1", "step2", "step3"]);
}

void testFindMatchSteps() {
    import tests.match;
    matchFuncCalls = [];

    auto steps = findSteps!"tests.match";
    auto regexen = [r"^I match a passing step$",
                    r"^I also match a passing step$",
                    r"^What about me. I also pass$",
                    r"I match a failing step$",
                    r"Gotta match pending"];

    checkEqual(steps.map!(a => a.regex).array,
               regexen.map!(a => std.regex.regex(a)).array);

    steps[0].func();
    checkEqual(matchFuncCalls, ["passingStep1"]);

    steps[1].func();
    checkEqual(matchFuncCalls, ["passingStep1", "passingStep2"]);

    steps[2].func();
    checkEqual(matchFuncCalls, ["passingStep1", "passingStep2", "passingStep3"]);

    checkThrown!Exception(steps[3].func());
    checkEqual(matchFuncCalls, ["passingStep1", "passingStep2", "passingStep3", "failingStep"]);
}

void testFindMatch() {
    reflectionFuncCalls = [];

    findMatch!__MODULE__("I match step1")();
    checkEqual(reflectionFuncCalls, ["step1"]);

    findMatch!__MODULE__("I think I match step2......")(); //extra chars, still matches
    checkEqual(reflectionFuncCalls, ["step1", "step2"]);
    findMatch!__MODULE__("Ooh, step3")();
    checkEqual(reflectionFuncCalls, ["step1", "step2", "step3"]);

    checkNull(findMatch!__MODULE__("Ooh, step3."));
    checkNull(findMatch!__MODULE__("random garbage"));
}
