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

private string[] funcCalls;

@Match!`^we're wired$`
void match1() {
    funcCalls ~= "match1";
}

@Match!`^2nd match$`
void match2() {
    funcCalls ~= "match2";
}

@Match!`^\drd .+`
void match3() {
    funcCalls ~= "match3";
}

@SingleThreaded
void testMatchesNoDetails() {
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
               `["success",[{"id":"1","args":[]}]]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"2nd match"}]`),
               `["success",[{"id":"2","args":[]}]]`);
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"3rd match"}]`),
               `["success",[{"id":"3","args":[]}]]`);
}

@SingleThreaded
void testMatchesDetails() {
    {
        auto reply = handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`, Yes.details);
        const json = parseJson(reply); //reply can't be const
        writelnUt("json is ", json);

        checkEqual(json[0].get!string, "success");
        checkEqual(json[1].length, 1);

        checkEqual(json[1][0].id.to!int, 1);
        checkEqual(json[1][0].args.length.to!int, 0);
        checkEqual(json[1][0].source.to!string, "tests.server.match1:18");
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
        checkEqual(json[1][0].source.to!string, "tests.server.match2:23");
        checkEqual(json[1][0].regexp.to!string, "^2nd match$");
    }
}

private auto jsonReply(string request) {
    auto reply = handleRequest!__MODULE__(request);
    return parseJson(reply);
}

@Match!`das pending1`
void pendingFunc1() {
    funcCalls ~= "pending1";
    pending("I'll do it later");
}

@Match!`das pending2`
void pendingFunc2() {
    funcCalls ~= "pending2";
    pending("But I'm le tired");
}


@SingleThreaded
void testInvokePending() {
    {
        const matchesReply = jsonReply(`["step_matches",{"name_to_match":"das pending1"}]`);
        const id = matchesReply[1][0].id.to!string;
        const beginReply = jsonReply(`["begin_scenario"]`);
        checkEqual(beginReply.toString(), `["success"]`);

        funcCalls = [];
        const invokeReply = jsonReply(`["invoke", {"id": "` ~ id ~ `", "args": []}]`);
        checkEqual(funcCalls, ["pending1"]);
        checkEqual(invokeReply[0], "pending");
        checkEqual(invokeReply[1], "I'll do it later");
    }
    {
        const matchesReply = jsonReply(`["step_matches",{"name_to_match":"das pending2"}]`);
        const id = matchesReply[1][0].id.to!string;
        const beginReply = jsonReply(`["begin_scenario"]`);
        checkEqual(beginReply.toString(), `["success"]`);

        funcCalls = [];
        const invokeReply = jsonReply(`["invoke", {"id": "` ~ id ~ `", "args": []}]`);
        checkEqual(funcCalls, ["pending2"]);
        checkEqual(invokeReply[0], "pending");
        checkEqual(invokeReply[1], "But I'm le tired");
    }
}

@SingleThreaded
void testInvokeNormal() {
    const matchesReply = jsonReply(`["step_matches",{"name_to_match":"we're wired"}]`);
    writelnUt("Reply: ", matchesReply);

    const beginReply = jsonReply(`["begin_scenario"]`);
    checkEqual(beginReply.toString(), `["success"]`);

    funcCalls = [];
    const id = matchesReply[1][0].id.to!string;
    const invokeReply = jsonReply(`["invoke", {"id": "` ~ id ~ `", "args": []}]`);
    writelnUt("Reply: ", invokeReply);

    checkEqual(funcCalls, ["match1"]);
    checkEqual(invokeReply[0], "success");
    checkEqual(invokeReply.length, 1);
}
