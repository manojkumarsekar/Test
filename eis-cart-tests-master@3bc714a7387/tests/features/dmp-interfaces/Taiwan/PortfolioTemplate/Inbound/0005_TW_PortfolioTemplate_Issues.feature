#https://collaborate.intranet.asia/display/TOMR4/TW+-+GS+portfolio+and+share+class+attibutes+%3A+Add+attributes+in+the+Portfolio+template
# https://jira.intranet.asia/browse/TOM-3686
# TOM-3686 : Adding new attributes for Taiwan LBU in the portfolio template
# TOM-4058 : Change then TW_FND_UNIFORM_NUM and TW_SITCA_FND_ID for portfolio as this was same in share class.
# https://jira.intranet.asia/browse/TOM-4139

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@tom_4139 @tom_4058 @tom_3686 @taiwan_new_port_attrb @taiwan_new_port_uat_Issues
Feature: This feature is to test the issues found during testing 3686 in UAT environment

  EISTOMTEST-3900 : Share class linked with multiple portfolios
  EISTOMTEST-3887 : Portfolio and Shareclass with same UBN overwrite each other

  One share class can not be linked with multiple main portfolio - TT56_TWD_A

  Scenario: TC1: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_Issues_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I execute below query
      """
      ${testdata.path}/sql/Acid_enddate.sql
      """
    And I assign "240" to variable "workflow.max.polling.time"

  Scenario: TC2:Load portfolio Template with Main portfolio, shareclass and link details to Setup new accounts in DMP

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  #defect EISTOMTEST-3887 found during UAT
  Scenario: TC3: Verify that Same UBN code for Portfolio and shareclass should not overwrite each other and should create 2 records in ACID table

    Then I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID IN ('TT27','TT56_USD_A')
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','UNIBUSNUM','SCUNIBUSNUM')
      """

  Scenario: TC4: Verify that Same SITCA code for Portfolio and shareclass should not overwrite each other and should create 2 records in ACID table

    Then I expect value of column "ACID_ROW_COUNT" in the below SQL query equals to "4":
      """
      SELECT COUNT(*) AS ACID_ROW_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID IN ('TT56_CNY','TT56_CNY_A')
        AND end_tms IS NULL
       )
       AND ACCT_ID_CTXT_TYP IN ('RDMID','SITCAFNDID','SCSITCAFNDID')
      """


  #defect EISTOMTEST-3900 found during automation
  Scenario: TC5: Verify that one shareclass  can not be linked with multiple main portfolio and it should override the existing one
  TT56_TWD_A	IS SHARE CLASS OF	TT56
  TT56_TWD_A	IS SHARE CLASS OF	TT56_S
  TT56_TWD_A	IS SHARE CLASS OF	TT56_USD


    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT56_TWD_B'
        AND end_tms IS NULL
      ) AND end_tms IS NULL
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory