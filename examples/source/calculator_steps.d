import calculator;
import cucumber;
import unit_threaded;

Calculator gCalculator;

@Given!`A calculator`
void givenACalc() {
    gCalculator = Calculator();
}


@When!`I add (\d+) and (\d+)`
void whenIadd(double a, double b) {
    gCalculator.add(a, b);
}


@Then!`^The result is (.+)$`
void thenResult(double result) {
    checkEqual(gCalculator.result, result);
}
