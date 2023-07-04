#https://collaborate.intranet.asia/display/TOMR4/TW+-+GS+portfolio+and+share+class+attibutes+%3A+Add+attributes+in+the+Portfolio+template
# https://jira.intranet.asia/browse/TOM-3686
# TOM-3686 : Adding new attributes for Taiwan LBU in the portfolio template
# TOM-4058 : Change the count of ACCR as match key added on ACCR segment so shareclass can not have multiple main portfolio
# https://jira.intranet.asia/browse/TOM-4139

@gc_interface_portfolios
@dmp_regression_unittest
@dmp_taiwan
@tom_4139 @tom_4058 @tom_3686 @taiwan_new_port_attrb @taiwan_new_links_attrb
Feature: This feature is to test the link between main portfolio and shareclass working or not with many comnination

  One main portfolio linked with multiple share class|TT56|
  One share class linked with one portfolio|TT32_TWD->TT32|
  Share class not linked with portfolio|TT56_USD_A|
  Portfolio linked with shared class and blank value|TT56_ZAR|

  Scenario: TC1: End date test accounts from ACID, ACDE and ACCR table table and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_portfolio_Links_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
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

  Scenario: TC3: Verify that one portfolio (TT56) can be linked with multiple shareclass
    #  TT56_TWD_A	IS SHARE CLASS OF	TT56
    #  TT56_TWD_B	IS SHARE CLASS OF	TT56
    #  TT56_USD_A	IS SHARE CLASS OF	TT56
    #  TT56_USD_B	IS SHARE CLASS OF	TT56
    #  TT56_AUD_A	IS SHARE CLASS OF	TT56
    #  TT56_AUD_B	IS SHARE CLASS OF	TT56
    #  TT56_ZAR_A	IS SHARE CLASS OF	TT56
    #  TT56_ZAR_B	IS SHARE CLASS OF	TT56
    #  TT56_CNY_A	IS SHARE CLASS OF	TT56
    #  TT56_CNY_B	IS SHARE CLASS OF	TT56

    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT56'
        AND end_tms IS NULL
      )
      """

  Scenario: TC4: Verify that one portfolio (TT32) can be linked with one shareclass
     # TT32_TWD	IS SHARE CLASS OF	TT32

    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT32'
        AND end_tms IS NULL
      )
      """

  Scenario: TC5: Verify that one shareclass  can not be linked with blank value for main portfolio in RELATED_CRTS_ID field
  #  TT56_USD_A	IS SHARE CLASS OF	TT56
  #  TT56_USD_A	IS SHARE CLASS OF

    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT56_USD_A'
        AND end_tms IS NULL
      )
      """

  Scenario: TC6: Verify that one main portfolio can not be linked with blank value for share class in CHILD_CRTS_RDM_ID field
  # TT56_USD_B	IS SHARE CLASS OF	TT56_ZAR
  #             IS SHARE CLASS OF	TT56_ZAR


    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE REP_ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT56_ZAR'
        AND end_tms IS NULL
      )
      """

  Scenario: TC7: Verify that one shareclass can be linked with One main portfolio and one hedge portfolio
  # TT56_TWD_A	IS SHARE CLASS OF TT56_S
  #             IS HEDGE BY	TT56_ZAR

    Then I expect value of column "ACCR_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS ACCR_ROW_COUNT FROM FT_T_ACCR
      WHERE ACCT_ID IN
      (
        SELECT ACCT_ID FROM FT_T_ACID
        WHERE ACCT_ALT_ID = 'TT56_TWD_A'
        AND end_tms IS NULL
      )
      AND RL_TYP IN ('HEDGE','SHRCLASS')
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory