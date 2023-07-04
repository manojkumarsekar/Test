#https://jira.intranet.asia/browse/TOM-4410
#Subscription and Redemption flow - Validating the filter conditions in F96 Load

@gc_interface_cash
@dmp_regression_unittest
@tom_4410
Feature: Taiwan | Portfolio Group Load | Relations not getting end_dated | SGLUKLNP already existing

  Below Scenarios are handled as part of this feature

  1. If NEWCASH.NEWCASH_ITEM.CONFIRMED_BY = "itap" and NEWCASH.NEWCASH_ITEM.PORTFOLIOS_PORTFOLIO_NAME is not part of portfolio group 'SGLUKLNP' then do not process the record.
  2. If NEWCASH.NEWCASH_ITEM.CONFIRMED_BY = "itap" and NEWCASH.NEWCASH_ITEM.PORTFOLIOS_PORTFOLIO_NAME is part of portfolio group 'SGLUKLNP' then process the record.
  3. If NEWCASH.NEWCASH_ITEM.CONFIRMED_BY <> "itap"  then process the record.

  Scenario: TC_1: Load New Cash File

    Given I assign "tests/test-data/DevTest/TOM-4410" to variable "testdata.path"
    And I assign "esi_newcash.xml" to variable "INPUT_FILE_NAME"

    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown_testdata.sql
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    Given I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: TC_2: Data Validations

    # Validation 1: Success row count should be 2
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT TASK_SUCCESS_CNT AS PROCESSED_ROW_COUNT FROM FT_T_JBLG WHERE job_id = '${JOB_ID}'
      """

    # Validation 2: Filtered row count should be 1
    Then I expect value of column "FILTERED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT TASK_FILTERED_CNT AS FILTERED_ROW_COUNT FROM FT_T_JBLG WHERE job_id = '${JOB_ID}'
      """
