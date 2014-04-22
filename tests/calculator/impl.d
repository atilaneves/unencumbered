module tests.calculator.impl;

import std.stdio;
import std.math;

struct Calculator {
    double result;

    void add(T...)(T args) {
        debug writeln("Adding args ", args);
        result = 0;
        foreach(a; args) result += a;
    }

    void computePi() {
        result = PI;
    }
}

package Calculator calculator;

bool closeEnough(T, U)(T a, U b) {
    return abs(a - b) < 1e-6;
}
