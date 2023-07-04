#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty
@dmp_regression_unittest
@dmp_taiwan
@tom_3873 @tw_onebroker_multipleissuer @tom_4094
Feature: Test the broker file from BRS all fields as per requirement One broker and Multiple issuer

  This feature file is to test the counter party file from BRS and all the fields are stored in DMP as required.
  Note: All the tags under <EXTERN_set > tag in brs file has been marked as descoped as per developers, so no coverage

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0008_OneBroker_MultipleIssuer.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//BROKER_ISSUER[text()='BF123_TEST']/../COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//BROKER_ISSUER[text()='BF123_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//BROKER_ISSUER[text()='BF123_TEST']/../BROKER_ISSUER" to variable "BROKER_ISSUER1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//BROKER_ISSUER[text()='BF124_TEST']/../BROKER_ISSUER" to variable "BROKER_ISSUER2"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//BROKER_ISSUER[text()='BF125_TEST']/../BROKER_ISSUER" to variable "BROKER_ISSUER3"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('BF123_TEST','1005_TEST','BF124_TEST','BF125_TEST')AND end_tms IS NULL );
    COMMIT
    """

# EISTOMTEST-3968
  Scenario: TC1: Load Broker file with One issuer(Existing/New) linked with multiple new brokers
  New Financial Institution for counterparty will be created along with its identifier, description and role in DMP.
  New Financial Institution for issuer will be created. Also, only one relationship between counterparty and brokerissuer is created.

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against COUNTERPARTY_CODE
    Then I expect value of column "FINS_COUNTRPRTY_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNTRPRTY_COUNT FROM FT_T_FINS
        WHERE PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND PREF_FINS_ID IN ('${COUNTERPARTY_CDE}')
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FINS_ISSR_COUNT" in the below SQL query equals to "3":
        """
        SELECT COUNT(*) AS FINS_ISSR_COUNT FROM FT_T_FINS
        WHERE INST_NME IN ('${COUNTERPARTY_NAME}')
        AND INST_DESC IN ('${COUNTERPARTY_NAME}')
        AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID IN ('${BROKER_ISSUER1}','${BROKER_ISSUER2}','${BROKER_ISSUER3}')
        AND DATA_SRC_ID = 'BRS'
        AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${BROKER_ISSUER1}','${BROKER_ISSUER2}','${BROKER_ISSUER3}') AND end_tms IS NULL)
        """

#  Links two Financial Institutions BROKER_ISSUER and COUNTERPARTY_NAME
    Then I expect value of column "FFRL_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FFRL_COUNT FROM FT_T_FFRL
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        AND PRNT_INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${BROKER_ISSUER1}','${BROKER_ISSUER2}','${BROKER_ISSUER3}') AND end_tms IS NULL)
        AND REL_TYP = 'PRIMBRKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """
