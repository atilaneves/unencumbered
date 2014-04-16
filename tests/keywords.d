module tests.keywords;

import unit_threaded;
import cucumber.match;

void testStripKeywords() {
    checkEqual("Given foo".stripCucumberKeywords, "foo");
    checkEqual("When bar".stripCucumberKeywords, "bar");
    checkEqual("When baz".stripCucumberKeywords, "baz");
    checkEqual("And asda".stripCucumberKeywords, "asda");
    checkEqual("But tesco".stripCucumberKeywords, "tesco");
}