@ignore_hooks @dummy @dummy2
Feature: Test

  @scn1
  Scenario: Test1

    Given I assign "Test1" to variable "var1"
    Given I assign "Test2" to variable "var2"

  @scn2
  Scenario: Test2

    Then I expect the value of var "${var1}" equals to "Test2"

  @scn3
  Scenario: Test3

    Then I expect the value of var "${var2}" equals to "Test1"

  @scn4
  Scenario: Test4

    Then I expect the value of var "${var1}" equals to "Test1"
    Then I expect the value of var "${var2}" equals to "Test2"

