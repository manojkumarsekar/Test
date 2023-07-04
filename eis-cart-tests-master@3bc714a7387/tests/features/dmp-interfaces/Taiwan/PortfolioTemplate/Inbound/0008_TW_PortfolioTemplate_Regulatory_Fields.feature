#https://jira.intranet.asia/browse/TOM-5268
  #https://jira.pruconnect.net/browse/EISDEV-6071
#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.
# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 16/10/2019      TOM-5268    R6 Reporting | Regulatory - Mapping new fields from 'Account' entity to GC
# 19/02/2020      EISDEV-6071  Regression failure :Feature file
# ===================================================================================================================================================================================

#https://collaborate.intranet.asia/display/TOMR4/Logical+Mapping+%3A-+Regulatory+-+Mapping+new+fields+from+%27Account%27+entity+to+GC
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=63084549

@gc_interface_portfolios @eisdev_7373
@dmp_regression_unittest
@dmp_taiwan
@tom_5268 @eisdev_6071 @eisdev_6173 @eisdev_7571
Feature: This feature is to test the mapping of US Person, Client Type

  Load portfolio template file having below scenario
  1. US Person flag tagged as Y
  2. US Person flag tagged as N
  3. Client Type flag tagged as D,E,F

  Scenario: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_portfolio_regulatory.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I execute below query
    """
    ${testdata.path}/sql/Regulatory_Acid_enddate.sql
    """

    And I execute below query to "Update FT_T_FINR entry"
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
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='15'
      """

  Scenario: Verify that US Person value gets populated as Y for portfolio TA5268,TB5268
    #  TA5268,TB5268 tagged as US Person "Y"

    Then I expect value of column "US_PERSON_Y_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS US_PERSON_Y_COUNT FROM FT_T_ACST
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'TA5268','TB5268')
        AND end_tms IS NULL
      ) AND stat_def_id in ('USPERSON') and end_tms is null and STAT_CHAR_VAL_TXT='Y'
      """

  Scenario: Verify that US Person value gets populated as N for portfolio LA5268,LB5268
      #  LA5268,LB5268 tagged as US Person "N"

    Then I expect value of column "US_PERSON_N_COUNT" in the below SQL query equals to "2":
    """
      SELECT COUNT(*) AS US_PERSON_N_COUNT FROM FT_T_ACST
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ( 'LA5268','LB5268')
        AND end_tms IS NULL
      ) AND stat_def_id in ('USPERSON') and end_tms is null and STAT_CHAR_VAL_TXT='N'
      """

  Scenario: Verify that Client Type value gets populated for portfolio TA5268,LA5268,TC5268,TD5268
    #  Client Type values tagged to TA5268,LA5268,TC5268,TD5268

    Then I expect value of column "CLIENT_TYPE_COUNT" in the below SQL query equals to "4":
    """
      SELECT COUNT(*) AS CLIENT_TYPE_COUNT FROM FT_T_ACCL
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID in ('TA5268','LA5268','TC5268','TD5268')
        AND end_tms IS NULL
      ) AND INDUS_CL_SET_ID='CLNTTYP' and end_tms is null and CL_VALUE in ('D','E','F')
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