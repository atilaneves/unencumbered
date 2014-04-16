module tests.keywords;

import unit_threaded;
import cucumber.match;

void testStripKeywords() {
    checkEqual("Given foo".stripCucumberKeywords, "foo");
    checkEqual("When bar".stripCucumberKeywords, "bar");
    checkEqual("When baz".stripCucumberKeywords, "baz");
    checkEqual("And asda".stripCucumberKeywords, "asda");
    checkEqual("    And asda".stripCucumberKeywords, "asda");
    checkEqual("But tesco".stripCucumberKeywords, "tesco");
    checkEqual("foo bar".stripCucumberKeywords, "foo bar");
    checkEqual("   foo bar".stripCucumberKeywords, "foo bar");
    checkEqual("    Given a calculator".stripCucumberKeywords, "a calculator");
    checkEqual("    And the calculator adds up 3 and 0.14159265".stripCucumberKeywords,
               "the calculator adds up 3 and 0.14159265");
}
