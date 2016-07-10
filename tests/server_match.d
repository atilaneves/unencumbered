module tests.server_match;

import cucumber;
import cucumber.reflection;
import unit_threaded;


void testNoMatches() {
    shouldEqual(findMatch!__MODULE__("foobarbaz"), MatchResult.init);
}

@Match(`^we are wired$`)
void wereWired() {
}

private void checkNumCaptures(in string[] captures, int num) {
    shouldEqual(captures.length, num + 1); //+1 because idx 0 is the whole thing
}

void testOneMatch() {
    auto match = findMatch!__MODULE__("we are wired");
    shouldBeTrue(cast(bool)match);
    checkNumCaptures(match.captures, 0);
    shouldEqual(match.id, 1); //1st one in the file
}

private int result;

@Match(`I add (\d+) and (\d+)`)
void addTwo(int a, int b) {
    result = a + b;
}

void testAddTwo() {
    const step_str = "I add 3 and 5";
    const func = findMatch!__MODULE__(step_str);
    result = 0;
    func();
    shouldEqual(result, 8);
    shouldEqual(func.captures, [step_str, "3", "5"]);
    shouldEqual(func.id, 2);
    shouldEqual(func.regex, `I add (\d+) and (\d+)`);
}
