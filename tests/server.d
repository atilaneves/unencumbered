module tests.server;

import unit_threaded;
import cucumber;
import vibe.data.json;

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


void testMatchesNoDetails() {
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
               `["success",[{"id":"1","args":[]}]]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"2nd match"}]`),
               `["success",[{"id":"2","args":[]}]]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"3rd match"}]`),
               `["success",[{"id":"3","args":[]}]]`);
}

void testMatchesDetails() {
    {
        auto reply = handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`, Yes.details);
        const json = parseJson(reply); //reply can't be const
        writelnUt("json is ", json);

        checkEqual(json[0].get!string, "success");
        checkEqual(json[1].length, 1);

        checkEqual(json[1][0].id.to!int, 1);
        checkEqual(json[1][0].args.length.to!int, 0);
        checkEqual(json[1][0].source.to!string, "tests.server.match1:17");
        checkEqual(json[1][0].regexp.to!string, "^we're wired$");
    }
    {
        auto reply = handleRequest!__MODULE__(`["step_matches",{"name_to_match":"2nd match"}]`, Yes.details);
        const json = parseJson(reply); //reply can't be const
        writelnUt("json is ", json);

        checkEqual(json[0].get!string, "success");
        checkEqual(json[1].length, 1);

        checkEqual(json[1][0].id.to!int, 2);
        checkEqual(json[1][0].args.length.to!int, 0);
        checkEqual(json[1][0].source.to!string, "tests.server.match2:21");
        checkEqual(json[1][0].regexp.to!string, "^2nd match$");
    }
}
