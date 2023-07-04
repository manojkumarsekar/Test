#https://jira.intranet.asia/browse/TOM-4140
  # ===================================================================================================================================================================================
# Date            JIRA         Comments
# ===================================================================================================================================================================================
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.
# ===================================================================================================================================================================================

@gc_interface_portfolios @eisdev_7373
@dmp_regression_unittest
@dmp_taiwan
@tom_4140 @eisdev_6071 @eisdev_6173 @eisdev_7571
Feature: Verify successful set up of account opening date in exac table by loading portfolio template file

  1. Clean up existing records and set up data
  2. Load new portfolio template to set up portfolio & account opening date in exac
  3. Perform verification whether portfolio got set up properly
  4. Perform verification whether account open date got set up properly in exac

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ExternalAccount/TOM-4140" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_ACID SET END_TMS = SYSDATE
     WHERE ACCT_ALT_ID = 'Test4140';
     COMMIT
    """

   # Insert supporting data in FINS, FIID, FINR for setting up portfolio template.

    And I execute below query to "Insert FT_T_FINR entry"
    """
    ${testdata.path}/sql/TOM_4140_INSERT_FINS_FINR_FIID.sql
    """

    #Clear FPRO Data
    And I execute below query to "End Date the FPRO data if exists"
      """
        UPDATE FT_T_FPRO SET END_TMS=SYSDATE-1
        WHERE FINS_PRO_ID='joanna.ong@eastspring.com' AND PRO_DESIGNATION_TXT='PM';
        COMMIT;
      """

    And I execute below query and extract values of "FPRO_OID;FINS_PRO_ID" into same variables
      """
       SELECT FPRO_OID,FINS_PRO_ID FROM FT_T_FPRO where ROWNUM=1 AND END_TMS IS NULL
      """

    And I execute below query to "Update PM mail id"
      """
        UPDATE FT_T_FPRO SET FINS_PRO_ID='joanna.ong@eastspring.com',PRO_DESIGNATION_TXT='PM'
        WHERE FPRO_OID='${FPRO_OID}';
        COMMIT
      """

  Scenario: Assigning variables and executing clean up

    Given I assign "4140_Portfolio_Template.xlsx" to variable "INPUT_FILENAME1"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

  Scenario: Load Portfolio file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='4'
    """

  Scenario: Performing portfolio verification

    # Verfication
    Then I expect value of column "PORTFOLIO_ROW_COUNT" in the below SQL query equals to "5":
    """
      select count(*) PORTFOLIO_ROW_COUNT from ft_t_acid where acct_alt_id ='Test4140' and end_tms is null
    """

  Scenario: Performing account opening date verification

    Then I expect value of column "ACCOUNT_OPEN_DATE_COUNT" in the below SQL query equals to "1":
    """
      select count(*) ACCOUNT_OPEN_DATE_COUNT from ft_t_exac where external_acct_id ='FIID_4140ExtSysId-4140:BROKER' and end_tms is null and to_date(acct_open_dte,'dd/MM/yy') =to_date('01/09/94','dd/MM/yy')
    """

  Scenario: Reverting the PM mail changes

    Then I execute below query to "Reverting the PM mail id changes"
    """
     UPDATE FT_T_FPRO SET FINS_PRO_ID='${FINS_PRO_ID}',PRO_DESIGNATION_TXT = NULL
     WHERE FPRO_OID='${FPRO_OID}';
     COMMIT
    """