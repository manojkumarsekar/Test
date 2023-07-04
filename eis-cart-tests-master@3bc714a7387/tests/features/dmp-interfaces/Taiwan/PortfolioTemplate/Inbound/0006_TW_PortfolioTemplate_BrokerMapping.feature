#https://collaborate.intranet.asia/display/TOMR4/TW+-+GS+portfolio+and+share+class+attibutes+%3A+Add+attributes+in+the+Portfolio+template
# https://jira.intranet.asia/browse/TOM-3686
# TOM-3686 : Adding new attributes for Taiwan LBU in the portfolio template
# https://jira.intranet.asia/browse/TOM-3930

@gc_interface_portfolios @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3930 @tom_3686 @taiwan_portfoliotemplate_broker
Feature: This feature is to test the new sheet broker added to portfolio template(4-Broker).
  Different permutation of data has been tested against the 4 fields BROKER, PROTFOLIO, EXTERNAL_ACCOUNT, BROKER_NAME

  Scenario: TC1: End date test accounts from ACID, ACDE , ACCR and FIID table  and setup variables and brokers

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioTemplate" to variable "testdata.path"
    And I assign "eis_dmp_portfolio_Broker_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "0001_Onebroker_OneIssuer.xml" to variable "BROKER_FILENAME"
    And I assign "200" to variable "workflow.max.polling.time"

    And I execute below query
    """
    ${testdata.path}/sql/Acid_enddate.sql
    """

    And I execute below query
    """
    DELETE FT_T_AEAR WHERE EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('CGMLG_TEST','49423_TEST','T_ABA-TW5_TEST','BFI_TEST')AND end_tms IS NULL));
    DELETE FT_T_EXAC WHERE INST_MNEM IN(SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('CGMLG_TEST','49423_TEST','T_ABA-TW5_TEST','BFI_TEST')AND end_tms IS NULL) AND END_TMS IS NULL;
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN
    (
      SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('CGMLG_TEST','49423_TEST','T_ABA-TW5_TEST','BFI_TEST')AND end_tms IS NULL
    );
    COMMIT
    """

    When I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BROKER_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BROKER_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='3'
      """

  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP

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

  Scenario: TC3: Verify BROKER, EXTERNAL_ACCOUNT,BROKER_NAME fields loaded into EXAC tables and PORTFOLIO into AEAR table for PORTFOLIO= TT27,TT56_CNY having different external account and name for BRSCNTCDE=CGMLG_TEST

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID IN ('CGMLG_TESTExtSysId-3930:BROKER','CGMLG_TESTExtSysId-39301:BROKER')
     AND EXT_ACCT_NME IN ('BrkNme3930','BrkNme39301')
     AND EXTERNAL_SYS_ACCT_ID IN ('ExtSysId-3930','ExtSysId-39301')
     AND INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('CGMLG_TEST') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME IN ('TT27', 'TT56_CNY'))
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('CGMLG_TEST') AND END_TMS IS NULL))
     AND END_TMS IS NULL
     """

  Scenario: TC4: Verify BROKER, EXTERNAL_ACCOUNT,BROKER_NAME fields loaded into EXAC tables and PORTFOLIO into AEAR table for PORTFOLIO= TT27_S , BRSTRDCNTCDE=CGMLG_TEST

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID='15972_TESTEXTID-BRSTRDCNTCDE-1234:BROKER'
     AND EXT_ACCT_NME='AccountName-TEST'
     AND EXTERNAL_SYS_ACCT_ID='EXTID-BRSTRDCNTCDE-1234'
     AND INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('15972_TEST') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME IN ('TT27_S'))
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('15972_TEST') AND END_TMS IS NULL))
     AND END_TMS IS NULL
     """

  Scenario: TC5: Verify BROKER, EXTERNAL_ACCOUNT,BROKER_NAME fields loaded into EXAC tables and PORTFOLIO into AEAR table for PORTFOLIO= TT56_USD, TT27_S having same external account and name for BRSCNTCDE=T_ABA-TW5_TEST

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID='T_ABA-TW5_TESTExtSysId-3930:BROKER'
     AND EXT_ACCT_NME='BrkNme3930'
     AND EXTERNAL_SYS_ACCT_ID='ExtSysId-3930'
     AND INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('T_ABA-TW5_TEST') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME IN ('TT27_S','TT56_USD'))
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('T_ABA-TW5_TEST') AND END_TMS IS NULL))
     AND END_TMS IS NULL
     """

  Scenario: TC6: Load Portfolio template with  BROKER, EXTERNAL_ACCOUNT,BROKER_NAME without PORTFOLIO,  BRSCNTCDE=T_ABA-TW5_TEST
  Expected Result: This record should not get loaded into EXAC /AEAR table as all the fields in Broker sheet are mandatory

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXTERNAL_ACCT_ID IN ('T_ABA-TW5_TESTExtSysId-3932:BROKER')
     AND EXT_ACCT_NME IN ('BrkNme3932')
     AND EXTERNAL_SYS_ACCT_ID IN ('ExtSysId-3932')
     AND INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('T_ABA-TW5_TEST') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

  Scenario: TC7: Load Portfolio template with  BROKER, PORTFOLIO,BROKER_NAME without EXTERNAL_ACCOUNT,  BRSCNTCDE=T_ABA-TW5_TEST
  Expected Result: This record should not get loaded into EXAC /AEAR table as all the fields in Broker sheet are mandatory

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXT_ACCT_NME IN ('BrkNme3933')
     AND INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('T_ABA-TW5_TEST') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME IN ('TT27'))
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE INST_MNEM IN(select INST_MNEM from ft_t_FIID where FINS_ID IN ('T_ABA-TW5_TEST') AND END_TMS IS NULL))
     AND END_TMS IS NULL
     """

  Scenario: TC8: Load Portfolio template with  PORTFOLIO,BROKER_NAME , EXTERNAL_ACCOUNT without broker
  Expected Result: This record should not get loaded into EXAC /AEAR table as all the fields in Broker sheet are mandatory

    Then I expect value of column "ID_COUNT_EXAC" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_EXAC
     FROM FT_T_EXAC
     WHERE EXT_ACCT_NME IN ('BrkNme3934')
     AND END_TMS IS NULL
     """

    Then I expect value of column "ID_COUNT_AEAR" in the below SQL query equals to "0":
    """
     SELECT COUNT(*) AS ID_COUNT_AEAR
     FROM FT_T_AEAR
     WHERE ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACCT WHERE ACCT_NME IN ('TT27'))
     AND EXAC_OID IN(SELECT EXAC_OID FROM FT_T_EXAC WHERE EXT_ACCT_NME IN ('BrkNme3934') AND END_TMS IS NULL)
     AND END_TMS IS NULL
     """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory