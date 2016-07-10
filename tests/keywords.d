module tests.keywords;

import unit_threaded;
import cucumber.keywords;

void testStripKeywords() {
    shouldEqual("Given foo".stripCucumberKeywords, "foo");
    shouldEqual("When bar".stripCucumberKeywords, "bar");
    shouldEqual("When baz".stripCucumberKeywords, "baz");
    shouldEqual("And asda".stripCucumberKeywords, "asda");
    shouldEqual("    And asda".stripCucumberKeywords, "asda");
    shouldEqual("But tesco".stripCucumberKeywords, "tesco");
    shouldEqual("foo bar".stripCucumberKeywords, "foo bar");
    shouldEqual("   foo bar".stripCucumberKeywords, "foo bar");
    shouldEqual("    Given a calculator".stripCucumberKeywords, "a calculator");
    shouldEqual("    And the calculator adds up 3 and 0.14159265".stripCucumberKeywords,
                "the calculator adds up 3 and 0.14159265");
}
