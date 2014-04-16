module tests.reflection;

import unit_threaded;
import cucumber.match;
import cucumber.reflection;


@Match!(r"^I match step1")
void step1() {
}

@Match!(r"^I think I match step2")
void step2() {
}

@Match!(r"^Ooh, step3$")
void step3() {
}

private {
    @Match!(r"Never going to see me")
    void privateStep();
}

void testFindSteps() {
    checkEqual(findSteps!(__MODULE__),
               [ CucumberStep(&step1, r"^I match step1"),
                 CucumberStep(&step2, r"^I think I match step2"),
                 CucumberStep(&step3, r"^Ooh, step3$") ]);
    import tests.match;
    checkEqual(findSteps!("tests.match"),
               [ CucumberStep(&passingStep1, r"^I match a passing step$"),
                 CucumberStep(&passingStep2, r"^I also match a passing step$"),
                 CucumberStep(&passingStep3, r"^What about me. I also pass$"),
                 CucumberStep(&failingStep, r"I match a failing step$"),
                 CucumberStep(&pendingStep, r"Gotta match pending")]);
}

void testFindMatch() {
    checkEqual(findMatch!__MODULE__("I match step1"), &step1);
    checkEqual(findMatch!__MODULE__("I think I match step2......"), &step2); //extra chars, still matches
    checkEqual(findMatch!__MODULE__("Ooh, step3"), &step3);
    void function() nullfunc;
    checkEqual(findMatch!__MODULE__("Ooh, step3."), nullfunc);
    checkEqual(findMatch!__MODULE__("random garbage"), nullfunc);
}
