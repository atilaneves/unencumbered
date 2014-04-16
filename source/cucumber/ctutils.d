module cucumber.ctutils;

string modulesString(Modules...)() {
    import std.array;
    string[] modules;
    foreach(mod; Modules) {
        modules ~= mod;
    }
    return modules.join(",");
}

string importModulesString(Modules...)() {
    return "import " ~ modulesString!Modules ~ ";";
}

private template HasAttribute(alias mod, string T, alias A) {
    mixin("import " ~ fullyQualifiedName!mod ~ ";"); //so it's visible
    enum index = staticIndexOf!(A, __traits(getAttributes, mixin(T)));
    static if(index >= 0) {
        enum HasAttribute = true;
    } else {
        enum HasAttribute = false;
    }
}
