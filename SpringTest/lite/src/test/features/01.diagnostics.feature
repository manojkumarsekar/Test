@diagnostics
Feature: framework diagnostic tests

  @jira-test01 @framework
  Scenario: TC_01: Test cucumber framework wiring
    Given the user run a dummy step

  @jira-test02
  Scenario Outline: TC_02: Test web-driver invocation
    Given the user open a browser
    Then the user close the browser

    Examples:
      | iteration |
      | 1         |
      | 2         |

  @jira-test03 @spark @noRun
  Scenario: TC_03: Test csv match
    Then the user expect "reference.csv" csv match with "reference.csv" csv as dataset

  @jira-test04 @framework
  Scenario: TC_04: Test csv lookup
    Then the user assert all records from "partialMatchTarget.csv" csv exist in "reference.csv" csv

  @jira-test05 @spark @noRun
  Scenario: TC_05: Test csv lookup
    Then the user assert all records as dataset from "partialMatchTarget.csv" csv exist in "reference.csv" csv

  @jira-test06
  Scenario Outline: TC_06: Test excel match
    Then the user expect records in "<sheetName>" sheet from "<targetFile>" excel match with "<referenceFile>" excel
    Examples:
      | sheetName         | targetFile                   | referenceFile                |
      | Consolidated_Data | sheet_with_invalid_cells.xls | sheet_with_invalid_cells.xls |
      | GHO_INS_OP        | sheet_with_invalid_cells.xls | sheet_with_invalid_cells.xls |
      | Submission_Report | matchingTarget.xlsx          | reference.xls                |

    @fail @noRun
    Examples:
      | sheetName         | targetFile       | referenceFile |
      | Submission_Report | targetSubset.xls | reference.xls |

  @jira-test07 @spark @noRun
  Scenario Outline: TC_07: Test excel lookup
    Then the user assert all records as dataset in "Submission_Report" sheet from "<targetFile>" excel exist in "<referenceFile>" excel
    Examples:
      | targetFile        | referenceFile  |
      | targetSubset.xls  | reference.xls  |
      | targetSubset.xlsx | reference.xlsx |