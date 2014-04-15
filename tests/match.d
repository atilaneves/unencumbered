module tests.match;
import unit_threaded;
import cucumber.match;

void testMatchPassing() {
    reset();
    Match!(r"^Foo bar$");
    checkEqual(getNumScenarios(), 1);
    checkEqual(getNumPassed(), 1);
    checkEqual(getNumPending(), 0);
}


void testMatchPending() {
    reset();
    Match!(r"^Foo bar$")(Yes.Pending);
    checkEqual(getNumScenarios(), 1);
    checkEqual(getNumPassed(), 0);
    checkEqual(getNumPending(), 1);
}
