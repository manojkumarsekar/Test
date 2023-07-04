@bdd @config_bdd
Feature: This feature is to test Config Steps Def code

  Scenario: I expect var1 equals to var2 - Single line expressions

    Given I assign "String1" to variable "var1"
    And I assign "String1" to variable "var2"
    Then I expect the value of var "${var1}" equals to "${var2}"

  Scenario: I expect var1 equals to var2 - Multiline expressions

    Given I assign below value to variable "var1"
    """
    This Sub-Fund invests in a diversified portfolio consisting primarily of fixed income/debt
    securities issued by Asian entities or their subsidiaries. This Sub-Fund’s portfolio primarily
    """

    And I assign below value to variable "var2"
    """
    This Sub-Fund invests in a diversified portfolio consisting primarily of fixed income/debt
    securities issued by Asian entities or their subsidiaries. This Sub-Fund’s portfolio
    primarily
    """

    Then I expect the value of var "${var1}" equals to "${var2}"



