module tests.match;
import unit_threaded;
import cucumber.match;

void testMatch() {
    Match!(r"^Foo bar$");
    checkEqual(getNumScenarios(), 1);
    checkEqual(getNumPassed(), 1);
}
