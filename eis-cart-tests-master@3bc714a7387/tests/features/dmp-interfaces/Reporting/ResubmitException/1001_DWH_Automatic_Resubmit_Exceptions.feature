#https://jira.intranet.asia/browse/TOM-5323
# 15/07/2020      EISDEV-6610  As part of this release 22, OOB Patch Starterset 128 has been updated which fixes the table name in NTEL exception
# 19/11/2020      EISDEV-7166  Input Layout Changes for BNP L1 file for 37 columns
# 15/01/2021      EISDEV-7323  Change in date format for L1 files

@dw_interface_performance
@dw_interface_resubmit_exception
@dmp_dw_regression
@tom_5323_resubmit_exceptions @tom_5323  @eisdev_6610 @perf_l1 @eisdev_7166  @eisdev_7323
Feature: Resubmit the DWH exceptions that need a fix in GS

  This is to test that the automatic resubmission of the exception occurs only for exception related to data missing in  GC and not for any other exceptions raised in DWH

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  @tom_5323_resubmit_exceptions_001
  #Assign variables
  Scenario: Clear existing Data, Setup data and assign variables

    Given I assign "tests/test-data/dmp-interfaces/Reporting/ResubmitException" to variable "testdata.path"
    And I assign "L1_Perf_ResubmitFunctionality.csv" to variable "PERF_INPUT_FILENAME"

    And I execute below query to "Cleanup existing data"
    """
    ${testdata.path}/sql/DataCleanupPreRequisite.sql
    """

    And I execute below query to "Setup test data"
      """
      ${testdata.path}/sql/AccountBMSetup.sql
      """

  #Load L1 file which has missing portfolio, missing benchmark association and missing required fields
  Scenario: Load L1 Performance file with data which would result in exceptions

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PERF_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${PERF_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_DWH_PERF_L1 |

    Then I extract new job id from jblg table into a variable "VAR_JOB_ID"

    Then I expect value of column "PERF_SCCS_COUNT" in the below SQL query equals to "0":
      """
      SELECT TASK_SUCCESS_CNT AS PERF_SCCS_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${VAR_JOB_ID}' AND JOB_INPUT_TXT LIKE '%${PERF_INPUT_FILENAME}%'
      """

    And I expect value of column "NTEL_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL WHERE LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${VAR_JOB_ID}' ) AND NOTFCN_STAT_TYP = 'OPEN'
      """

  #Verify no records have been inserted in wcri table
  Scenario Outline: Verify no records have been created in wcri table

    And I expect value of column "WCRI_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI
      WHERE ACCT_SOK IN
       (SELECT ACCT_SOK FROM FT_T_WACT
        WHERE INTRNL_ID10 = '<INTERNAL_ID_10>') AND DW_STATUS_NUM ='1'
      """

    Examples:
      | INTERNAL_ID_10 |
      | RESUBEXCPFL1   |
      | RESUBEXCPFL2   |
      | RESUBEXCPFL3   |


  #Fix the data issues by creating the portfolio and L1BM association and Resubmit the exceptions
  Scenario: Insert the missing portfolio and the Portfolio - BM Relationship

    When I execute below query
      """
      ${testdata.path}/sql/FixDataIssues.sql
      """

    And I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ResubmitBulkExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ResubmitBulkExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

  #Verify GC related exceptions have been resubmitted
  Scenario Outline: Verify the GC related exceptions are resubmitted

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI
      WHERE ACCT_SOK IN
      (SELECT ACCT_SOK FROM FT_T_WACT
        WHERE INTRNL_ID10 = '<INTERNAL_ID_10>') AND DW_STATUS_NUM ='1'
      """

    Examples:
      | INTERNAL_ID_10 |
      | RESUBEXCPFL1   |
      | RESUBEXCPFL2   |

  #Verify dmp related exceptions have not been resubmitted
  Scenario: Verify the DWH related exceptions are not resubmitted

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS WCRI_COUNT
      FROM FT_T_WCRI
      WHERE ACCT_SOK IN
       (SELECT ACCT_SOK FROM FT_T_WACT
        WHERE INTRNL_ID10 = 'RESUBEXCPFL3') AND DW_STATUS_NUM ='1'
      """