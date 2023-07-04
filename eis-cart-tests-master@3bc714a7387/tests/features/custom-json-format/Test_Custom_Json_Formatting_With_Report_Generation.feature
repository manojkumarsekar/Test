@custom_json_format_test @ignore_hooks
Feature: This feature is to test Custom Json Formatting plugin

  As a Automation developer
  when I use Custom Json Formatting Plugin which is developed in-house
  then I expect html reports should get genarated successfully
  and I expect variables are expanded properly in html reports
  and I expect passwords with in-string ".pass" are masked with **** in html reports

  To get framework to pick custom json plugin, set cucumber.json.apply.custom.formatter=true
  and to mask passwords in reports, set cucumber.json.allow.masking.secrets=true in tomcart-private.properties

  Scenario: Set all Prerequisite variables used in test

    Given I assign "password" to variable "test.pass"
    * I assign "more characters" to variable "more.chars"
    * I assign "less" to variable "less.chars"
    * I assign "equal chars" to variable "equal.chars"
    * I assign below value to variable "multi.line.var"
    """
    This is to test doc string expansi.
    """

  Scenario: Test all combinations of with dummy step definitions

    Given Assign "${test.pass}" to "TEST_PASSWORD"
    * Assign "${test.empty}" to "TEST_EMPTY"

    * Assign "${more.chars}" to "TEST_MORE_CHARS"
    * Assign "${less.chars}" to "TEST_LESS_CHARS"
    * Assign "${equal.chars}" to "TEST_EQUAL_CHARS"
    * Assign "${multi.line.var}" to "TEST_EXTREME_CHARS"
    * Assign "amend_new_data_${equal.chars}" to "TEST_EXTRA_CHARS"

    * Expand var1 "${equal.chars}"
    * Expand var1 "${more.chars}" var2 "${less.chars}"
    * Expand var1 "${more.chars}" var2 "${more.chars}" and var3 "${more.chars}"
    * Expand var1 "${less.chars}" var2 "${more.chars}" and var3 "${less.chars}"
    * Expand var1 "${test.empty}" var2 "${test.empty}" and var3 "${test.empty}"
    * Expand var1 "${less.chars}" var2 "${test.empty}" and var3 "${more.chars}"
    * Expand var1 "${test.empty}" var2 "${test.empty}" and var3 "${more.chars}"
    * Expand var1 "1_${test.empty}" var2 "2_${test.empty}" and var3 "3_${more.chars}"

    * Expand var1 "x" var2 "y" and var3 "${less.chars}"
    * Expand var1 "${less.chars}" var2 "y" and var3 "z"
    * Expand var1 "x" var2 "${more.chars}" and var3 "z"

    * Expand below cells
      | expand_${more.chars} |
      | expand_${less.chars} |

    * I Expand below doc_string
    """
    Expand doc string with ${more.chars}
    """
