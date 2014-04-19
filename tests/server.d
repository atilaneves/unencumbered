module tests.server;

import unit_threaded;
import cucumber;

void testFail() {
    checkEqual(handleRequest!__MODULE__("fsafs"), `["fail"]`);
    checkEqual(handleRequest!__MODULE__(`["foo"]`), `["fail"]`);
}

void testNoMatches() {
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"foo"}]`), `["success",[]]`);
}

@Match!`^we're wired$`
void match1() {
}

@Match!`^2nd match$`
void match2() {
}

@Match!`^\drd .+`
void match3() {
}


void testMatches() {
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
               `["success",{"id":"1","args":[]}]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"2nd match"}]`),
               `["success",{"id":"2","args":[]}]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"3rd match"}]`),
               `["success",{"id":"3","args":[]}]`);
}
