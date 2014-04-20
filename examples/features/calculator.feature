Feature: Calculator
  Scenario: Adding 2 numbers
    Given a calculator
    When the calculator adds up 3 and 4
    Then the calculator returns "7"
