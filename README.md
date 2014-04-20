unencumbered
============
[![Build Status](https://travis-ci.org/atilaneves/unencumbered.png?branch=master)](https://travis-ci.org/atilaneves/unencumbered)

Unencumbered allows Cucumber to support step definitions written in D.

This is done by implementing the Cucumber [wire protocol](https://github.com/cucumber/cucumber/wiki/Wire-Protocol).
The best way to get a feel for how it's used is to look at the [calculator example](examples/app.d). To run it,
type `dub run` in the [examples](examples) directory and `cucumber` from the same directory in another shell.

Unencumbered works by using compile-time reflection to find all the Cucumber step definitions written in D.
That means that the server to be run for testing needs to make a call to `runCucumberServer` with
all the modules to include in the search as compile-time string parameters.

Notice that the calculator examples use functions that take arguments of `double` type, not `string`.
If a function is registered with types that don't match at run-time, an exception will be thrown. If a
function with arity different from the number of capturing parentheses is registered, the code will not
compile.
