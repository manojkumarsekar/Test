#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty
@dmp_regression_unittest
@dmp_taiwan
@tom_3873 @tw_broker_missing_counterpartyname @tom_4094
Feature: Test the broker file from BRS with missing counteropaty_name

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0002_Broker_Missing_Cpty_name.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "BROKER_TICKER" to variable "BROKER_TICKER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "BROKER_ISSUER" to variable "BROKER_ISSUER"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('C87335_TEST','9001_TEST')AND end_tms IS NULL );
    COMMIT
    """

  Scenario: TC1: Load Broker file load without counterparty_name
  Expected Result: FINS and FIDE table populated with INST_NME and INST_DESC values as BROKER_ISSUER and COUNTERPARTY_CODE

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against COUNTERPARTY_CODE
    Then I expect value of column "FINS_COUNTRPRTY_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNTRPRTY_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_CDE}'
        AND INST_DESC = '${COUNTERPARTY_CDE}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND PREF_FINS_ID = '${COUNTERPARTY_CDE}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM = (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FINS_ISSR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_ISSR_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${BROKER_ISSUER}'
        AND INST_DESC = '${BROKER_ISSUER}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM = (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${BROKER_ISSUER}') AND end_tms IS NULL)
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FIDE Table
    Then I expect value of column "FIDE_CNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIDE_CNTCDE_COUNT FROM FT_T_FIDE
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        AND INST_DESC = '${COUNTERPARTY_CDE}'
        AND INST_NME = '${COUNTERPARTY_CDE}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

#  Links two Financial Institutions BROKER_ISSUER and COUNTERPARTY_NAME
    Then I expect value of column "FFRL_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FFRL_COUNT FROM FT_T_FFRL
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        AND PRNT_INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${BROKER_ISSUER}') AND end_tms IS NULL)
        AND REL_TYP = 'PRIMBRKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory