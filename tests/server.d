module tests.server;

import unit_threaded;
import cucumber.server;
import vibe.data.json;


void testFail() {
    checkEqual(handleRequest!__MODULE__("fsafs"), `["fail"]`);
    checkEqual(handleRequest!__MODULE__(`["foo"]`), `["fail"]`);
}

void testNoMatches() {
    checkEqual(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"foo"}]`), `["success",[]]`);
}

private string[] funcCalls;

@Match(`^we're wired$`)
void match1() {
    funcCalls ~= "match1";
}

@Match(`^2nd match$`)
void match2() {
    funcCalls ~= "match2";
}

@Match(`^\drd .+`)
void match3() {
    funcCalls ~= "match3";
}

void checkSuccessJson(string str, in string id, in string[] args) {
    import std.algorithm;
    auto json = parseJson(str);
    checkEqual(json[0], "success");
    auto obj = json[1][0];
    checkEqual(obj["id"], id);
    string[] objArgs;
    foreach(arg; obj["args"])
        objArgs ~= arg.toString;
    checkEqual(objArgs, args);
}

@SingleThreaded
void testMatchesNoDetails() {
    checkSuccessJson(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
                     "1", []);
    checkSuccessJson(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
                     "1", []);
    checkSuccessJson(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"we're wired"}]`),
                     "1", []);
    checkSuccessJson(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"2nd match"}]`),
                     "2", []);
    checkSuccessJson(handleRequest!__MODULE__(`["step_matches",{"name_to_match":"3rd match"}]`),
                     "3", []);

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
        checkEqual(json[1][0].source.to!string, "tests.server.match1:19");
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
        checkEqual(json[1][0].source.to!string, "tests.server.match2:24");
        checkEqual(json[1][0].regexp.to!string, "^2nd match$");
    }
}

private auto jsonReply(string request) {
    auto reply = handleRequest!__MODULE__(request);
    return parseJson(reply);
}

@Match(`das pending1`)
void pendingFunc1() {
    funcCalls ~= "pending1";
    pending("I'll do it later");
}

@Match(`das pending2`)
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
void testInvokePass() {
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

    const endReply = jsonReply(`["end_scenario"]`);
    checkEqual(endReply.toString(), `["success"]`);
}

class TestException: Exception {
    this(string msg) {
        super(msg);
    }
}

@Given(`oops gonna fail`)
void gonnaFail() {
    funcCalls ~= "gonna fail";
    throw new TestException("I did it again");
}

@SingleThreaded
void testInvokeFail() {
    const matchesReply = jsonReply(`["step_matches",{"name_to_match":"oops gonna fail"}]`);
    writelnUt("Reply: ", matchesReply);

    const beginReply = jsonReply(`["begin_scenario"]`);
    checkEqual(beginReply.toString(), `["success"]`);

    funcCalls = [];
    const id = matchesReply[1][0].id.to!string;
    const invokeReply = jsonReply(`["invoke", {"id": "` ~ id ~ `", "args": []}]`);
    writelnUt("Reply: ", invokeReply);

    writelnUt("Start of the checks");
    checkEqual(funcCalls, ["gonna fail"]);
    checkEqual(invokeReply.length, 2);
    checkEqual(invokeReply[0], "fail");
    checkEqual(invokeReply[1].message.to!string, "I did it again");
    checkEqual(invokeReply[1].exception.to!string, "tests.server.TestException");

    const endReply = jsonReply(`["end_scenario"]`);
    checkEqual(endReply.toString(), `["success"]`);
}
