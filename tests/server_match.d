module tests.server_match;

import cucumber;
import cucumber.reflection;
import unit_threaded;


void testNoMatches() {
    checkEqual(findMatch!__MODULE__("foobarbaz"), MatchResult(null, []));
}

@Match!`^we're wired$`
void wereWired() {
}

private void checkNumCaptures(in string[] captures, int num) {
    checkEqual(captures.length, num + 1); //+1 because idx 0 is the whole thing
}

void testOneMatch() {
    auto match = findMatch!__MODULE__("we're wired");
    checkTrue(match);
    checkNumCaptures(match.captures, 0);
}
