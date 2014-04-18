module tests.server;

import unit_threaded;
import cucumber;

void testFail() {
    checkEqual(handleRequest("fsafs"), `["fail"]`);
    checkEqual(handleRequest(`["foo"]`), `["fail"]`);
}
