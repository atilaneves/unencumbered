module cucumber.keywords;

import std.string;

struct Match {
    string reg;
    ulong line;
    this(in string reg, in ulong line = __LINE__) {
        this.reg = reg;
        this.line = line;
    }
}

alias Given = Match;
alias When = Match;
alias Then = Match;
alias And = Match;
alias But = Match;

string stripCucumberKeywords(string str) {
    string stripImpl(string str, in string keyword) {
        str = str.stripLeft;
        if(str.startsWith(keyword)) {
            return std.array.replace(str, keyword, "");
        } else {
            return str;
        }
    }

    foreach(keyword; ["Given", "When", "Then", "And", "But"]) {
        str = stripImpl(str, keyword);
    }

    return str.stripLeft;
}
