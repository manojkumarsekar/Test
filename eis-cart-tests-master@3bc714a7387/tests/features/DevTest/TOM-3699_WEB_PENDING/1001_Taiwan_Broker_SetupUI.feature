#https://jira.intranet.asia/browse/TOM-3699
#https://collaborate.intranet.asia/display/TOM/R5.IN-TRAN05+DMP-%3ECIS+Order+Placement
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45858121
#TOM-3699 => CIS Orders : TW broker mappings Fund Vs Security Vs Broker Mapping
#TOM-4055 => ID Ctxt Type for Taiwan Broker Code - BRSBROKER changed to BRSTRDCNTCDE
@tom_3699 @tom_4055 @web @gs_ui_exception @ignore
Feature: Create the Taiwan Broker setup for ISIN and Portfolio and system should not create the same combination again

  This screen contain 3 lookup fields (i.e Portfolio, ISIN and Taiwan Broker code) and all are mandatory.
  This feature file can be used to create the New Taiwan broker setup and system should not create the same combination again.
  This handles both the maker checker event.
  This screen is available in Generic Setup - Taiwan Broker setup

  Below Steps are following to validate this testing

  PreRequest
  1. Create the Broker with ID_CTXT_TYP AS "BRSTRDCNTCDE" in FT_T_FIID
  2. Clear the old data in CCRF table

  Testcase
  3. Create the Taiwan Broker setup for ISIN and Portfolio with maker and checker event
  4. Create the same combination again and system should not save and display the error message from UI screen


  Scenario: Create the Broker with ID_CTXT_TYP AS "BRSTRDCNTCDE" in FT_T_FIID
    Given I assign "GMN US MULTI-FACTOR EQUITY SUB-FUND" to variable "PORTFOLIO_NAME"
    And I assign "CNE100001VR3" to variable "ISIN"
    And I assign "ANZG-ES" to variable "TAIWAN_BROKER_CODE"
    And I assign "ALGMUS" to variable "PORTFOLIO_NAME"

    Given I execute below query
	  """
      INSERT INTO FT_T_FIID (
      FIID_OID, INST_MNEM, FINS_ID_CTXT_TYP, FINS_ID, START_TMS, END_TMS, LAST_CHG_TMS, LAST_CHG_USR_ID, INST_SYMBOL_STAT_TYP, DATA_STAT_TYP, DATA_SRC_ID, GU_ID, GU_TYP, GU_CNT, MERGE_UNIQ_OID, INST_USAGE_TYP, INST_SYMBOL_STAT_TMS, SRCE_INST_MNEM, GLOBAL_UNIQ_IND, INST_SYMBOL_RENEW_TMS)
      SELECT NEW_OID,(select nvl(INST_MNEM,'X') from FT_T_FINS WHERE INST_NME in ('${TAIWAN_BROKER_CODE}') AND END_TMS IS NULL), 'BRSTRDCNTCDE', '${TAIWAN_BROKER_CODE}', SYSDATE, NULL, SYSDATE, 'EIS:CSTM', NULL, NULL, 'EIS', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL
      FROM DUAL
      WHERE NOT EXISTS ( SELECT 1
      FROM FT_T_FIID
      WHERE INST_MNEM = (select nvl(INST_MNEM,'X') from FT_T_FINS WHERE INST_NME in ('${TAIWAN_BROKER_CODE}') AND END_TMS IS NULL) AND   FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE' AND   FINS_ID = '${TAIWAN_BROKER_CODE}' AND   END_TMS IS NULL )
      """

  Scenario: Clear the old data
    And I execute below query
	  """
	  UPDATE FT_T_CCRF SET END_TMS = SYSDATE
	  WHERE  FINR_FINSRL_TYP='BROKER' AND CROSS_REF_PURP_TYP='BROKER' AND
             ACCT_ID=(SELECT ACID.ACCT_ID FROM FT_T_ACID ACID WHERE ACID.ACCT_ID_CTXT_TYP = 'CRTSID' AND ACID.END_TMS IS NULL AND ACID.ACCT_ALT_ID='${PORTFOLIO_NAME}') AND
             FINR_INST_MNEM=(SELECT FIID.INST_MNEM FROM FT_T_FIID FIID WHERE  FIID.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE' AND FIID.END_TMS IS NULL AND FIID.FINS_ID='${TAIWAN_BROKER_CODE}') AND
             INSTR_ID=(SELECT ISID.INSTR_ID FROM FT_T_ISID ISID WHERE ISID.ID_CTXT_TYP = 'ISIN' AND ISID.END_TMS IS NULL  AND ISID.ISS_ID='${ISIN}' ) AND
             END_TMS IS NULL
      """

  Scenario: Create the Taiwan Broker setup for ISIN and Portfolio with maker and checker event
    Given I login to golden source UI with "task_assignee" role
    And I navigate "Generic Setup : Taiwan Broker setup" screen

    When I add Taiwan Broker setup as below
      | Portfolio Name         | ${PORTFOLIO_NAME}     |
      | ISIN                   | ${ISIN}               |
      | Taiwan BRS Broker Code | ${TAIWAN_BROKER_CODE} |

    And I save the Taiwan Broker setup details
    Then I expect the Taiwan Broker setup record is moved to My WorkList for approval

    When I relogin to golden source UI with "task_authorizer" role
    And I approve Taiwan Broker setup record

    When I relogin to golden source UI with "task_assignee" role
    Then I expect Taiwan Broker setup is created

  Scenario: Create the same combination again and system should not save and display the error message from UI screen
    And I navigate "Generic Setup : Taiwan Broker setup" screen

    When I add Taiwan Broker setup as below
      | Portfolio Name         | ${PORTFOLIO_NAME}     |
      | ISIN                   | ${ISIN}               |
      | Taiwan BRS Broker Code | ${TAIWAN_BROKER_CODE} |

    And I save the Taiwan Broker setup details
    Then I expect the Error message conains This combination is already exist

  Scenario: Close browsers
    Then I close all opened web browsers


