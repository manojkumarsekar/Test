#https://jira.intranet.asia/browse/TOM-1429
@tom_1429 @web @gs_ui_exception
Feature: Added Short Description field in the Exception search screen
  Current description provided for Exceptions in Goldensource OOB are not user friendly. In some cases difficult to understand or read.
  hence, Short Description of the exception is added on the exception search screen

  Scenario: Verify if Short Description field is present on search

    Given I login to golden source UI with "task_assignee" role
    And I navigate "Exception management : Transaction & Exceptions" screen
    Then I should see a field "Short Description"

  Scenario: Close browsers
    Then I close all opened web browsers