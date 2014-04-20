module tests.server_match;

import cucumber;
import cucumber.reflection;
import unit_threaded;


void testNoMatches() {
    checkEqual(findMatch!__MODULE__("foobarbaz"), MatchResult.init);
}

@Match!`^we are wired$`
void wereWired() {
}

private void checkNumCaptures(in string[] captures, int num) {
    checkEqual(captures.length, num + 1); //+1 because idx 0 is the whole thing
}

void testOneMatch() {
    auto match = findMatch!__MODULE__("we are wired");
    checkTrue(match);
    checkNumCaptures(match.captures, 0);
    checkEqual(match.id, 1); //1st one in the file
}

private int result;

@Match!`I add (\d+) and (\d+)`
void addTwo(int a, int b) {
    result = a + b;
}

void testAddTwo() {
    const step_str = "I add 3 and 5";
    const func = findMatch!__MODULE__(step_str);
    result = 0;
    func();
    checkEqual(result, 8);
    checkEqual(func.captures, [step_str, "3", "5"]);
    checkEqual(func.id, 2);
    checkEqual(func.regex, `I add (\d+) and (\d+)`);
}
