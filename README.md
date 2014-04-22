unencumbered
============
[![Build Status](https://travis-ci.org/atilaneves/unencumbered.png?branch=master)](https://travis-ci.org/atilaneves/unencumbered)

Unencumbered allows [Cucumber](https://github.com/cucumber/cucumber/wiki)
to support step definitions written in [D](http://dlang.org/).

This is done by implementing the Cucumber
[wire protocol](https://github.com/cucumber/cucumber/wiki/Wire-Protocol).
The best way to get a feel for how it's used is to look at the
[calculator example](examples/source/app.d). To run it,type `dub run` in the
[examples](examples) directory and `cucumber` from the same directory in another shell.

Unencumbered works by using compile-time reflection to find all the
Cucumber step definitions written in D. That means that the server to be run
for testing needs to make a call to `runCucumberServer` with
all the modules to include in the search as compile-time string parameters.

Notice that the [calculator example steps](tests/calculator/steps.d) register
functions that vary in the number of arguments they can take, as well as
the type of those arguments. Some have to parameters, some take `double`
parameters and one takes just one `string` argument.
The compile-time reflection generates code to convert any regular expression
capturing parentheses matches to the type(s) in the function declaration.

If the type is not convertible at run-time, an exception will be thrown.
If a function with arity different from the number of capturing parentheses
is registered, the code will not compile (try it and see!).
If the regular expression is invalid (e.g. because a capturing parenthesis
is never closed), a compile-time (CTFE) exception is thrown, so the code
won't compile in that case either.

Step definitions are supposed to test the code and signal failure by
throwing any `Throwable`. The examples use the
[`check` functions](https://github.com/atilaneves/unit-threaded/blob/master/source/unit_threaded/check.d)
from
[unit-threaded](https://github.com/atilaneves/unit-threaded), but regular
`assert` or anything else that throws on failure would work too.
Unencumbered actually reports the exception type and message
back to Cucumber over the wire protocol.
