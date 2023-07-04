@dmp_regression_integrationtest @dmp_regression_unittest @trigger_initial_load

Feature: This feature is to trigger a load job at the beginning of the pipeline

  Scenario: Load Security file
    Given I assign "tests/test-data/0000_Start_Of_Execution" to variable "testdata.path"
    And I assign "0002_load_job_at_beginning_of_pipeline_testdata.xml" to variable "INPUT_FILENAME"
    And I assign "120" to variable "workflow.max.polling.time"

    And I process "${testdata.path}/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |