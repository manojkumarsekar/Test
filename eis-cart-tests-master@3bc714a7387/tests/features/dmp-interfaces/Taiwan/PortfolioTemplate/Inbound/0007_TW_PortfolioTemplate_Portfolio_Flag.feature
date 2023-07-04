#https://jira.intranet.asia/browse/TOM-5127
#https://jira.pruconnect.net/browse/EISDEV-6071 - Regression failure added "6071-finrInsert"
#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.
# ===================================================================================================================================================================================
# Date            JIRA         Comments
# ===================================================================================================================================================================================
# 05/09/2019      TOM-5127     R6 Reporting | Create a performance flag in Portfolio Master
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=63084549

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@tom_5127 @eisdev_6071 @eisdev_6173 @eisdev_7174 @eisdev_7571
Feature: This feature is to test the link of carve out and portfolio performance including testing of BNP portfolio performance flag

  Scenario: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_portfolio_performance.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I execute below query
    """
    ${testdata.path}/sql/Portfolio_flag_Acid_enddate.sql
    """

    And I execute below query to "Insert FT_T_FINR entry"
    """
    ${testdata.path}/sql/6071_FinrInsert.sql
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

    And I assign "240" to variable "workflow.max.polling.time"

  Scenario: Load portfolio Template with Main portfolio, shareclass and link details to Setup new accounts in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='12'
    """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_FAILED_CNT ='3'
    """

  Scenario: Verify that BNP CARVED OUT relation is set between two portfolios
    #  LA5127 IS BNP CARVED OUT OF TA5127

    Then I expect value of column "ACCR_ROW_COUNT_1" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT_1 FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'TA5127')
        AND end_tms IS NULL
      ) AND RL_TYP ='CARVEOUT' AND end_tms IS NULL
      """

  Scenario: Verify that BNP PERFORMANCE PORTFOLIO relation is set between two portfolios
  LB5127 IS BNP PERFORMANCE PORTFOLIO OF	TB5127

    Then I expect value of column "ACCR_ROW_COUNT_2" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ACCR_ROW_COUNT_2 FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'TB5127')
        AND end_tms IS NULL
      ) AND RL_TYP ='PERFPORT' AND end_tms IS NULL
      """

  Scenario: Verify that hedge relation is set between two portfolios
  SC5127 IS HEDGE BY OF	TC5127
  SD5127 IS HEDGE BY OF	TD5127

    Then I expect value of column "ACCR_ROW_COUNT_3" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS ACCR_ROW_COUNT_3 FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'TC5127','TD5127')
        AND end_tms IS NULL
      ) AND RL_TYP ='HEDGE' AND end_tms IS NULL
      """

  Scenario: Verify that hedge relation is not set between two portfolios
  SE5127 IS HEDGE BY OF	TE5127

    Then I expect value of column "ACCR_ROW_COUNT_4" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ACCR_ROW_COUNT_4 FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'TE5127')
        AND end_tms IS NULL
      ) AND RL_TYP ='HEDGE' AND end_tms IS NULL
      """

  Scenario: Verify that BNP PERFORMANCE PORTFOLIO flag is set to Y for LA5127, LB5127, SC5127
  BNP Portfolio Performance Flag for LA5127, LB5127, SC5127 is set to Y

    Then I expect value of column "ACST_ROW_COUNT_1" in the below SQL query equals to "5":
    """
      SELECT COUNT(*) AS ACST_ROW_COUNT_1 FROM FT_T_ACST
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'LA5127','LB5127','SC5127','TB5127','TC5127')
        AND end_tms IS NULL
      )
      AND STAT_DEF_ID ='PORTFLAG'
      AND STAT_CHAR_VAL_TXT='Y'
      AND end_tms IS NULL
      """

  Scenario: Verify that BNP PERFORMANCE PORTFOLIO flag is set to N for SD5127
  BNP Portfolio Performance Flag for SD5127 is set to N

    Then I expect value of column "ACST_ROW_COUNT_2" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS ACST_ROW_COUNT_2 FROM FT_T_ACST
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'SD5127','TA5127','TD5127')
        AND end_tms IS NULL
      )
      AND STAT_DEF_ID ='PORTFLAG'
      AND STAT_CHAR_VAL_TXT='N'
      AND end_tms IS NULL
      """

  Scenario: Verify that BNP PERFORMANCE PORTFOLIO flag is set to neither Y or N for SE5127
  BNP Portfolio Performance Flag for SE5127 is set to neither Y or N for SE5127

    Then I expect value of column "ACST_ROW_COUNT_3" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ACST_ROW_COUNT_3 FROM FT_T_ACST
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'SE5127','TE5127')
        AND end_tms IS NULL
      )
      AND STAT_DEF_ID ='PORTFLAG'
      AND end_tms IS NULL
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory

  Scenario: Reverting the PM mail changes

    Then I execute below query to "Reverting the PM mail id changes"
    """
     UPDATE FT_T_FPRO SET FINS_PRO_ID='${FINS_PRO_ID}',PRO_DESIGNATION_TXT = NULL
     WHERE FPRO_OID='${FPRO_OID}';
     COMMIT
    """