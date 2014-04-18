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
