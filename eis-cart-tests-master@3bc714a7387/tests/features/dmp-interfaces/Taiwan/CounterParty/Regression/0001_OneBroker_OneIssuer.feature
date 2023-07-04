#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty
@dmp_regression_unittest
@dmp_taiwan
@tom_3873 @tw_onebroker_oneissuer @tom_4094
Feature: Test the broker file from BRS all fields as per requirement with existing and new issuer
  This feature file is to test the counter party file from BRS and all the fields are stored in DMP as required.
  Note: All the tags under <EXTERN_set > tag in brs file has been marked as descoped as per developers, so no coverage

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0001_Onebroker_OneIssuer.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='15972_TEST']/../COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='15972_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='15972_TEST']/../BROKER_TICKER" to variable "BROKER_TICKER"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='15972_TEST']/../TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='15972_TEST']/../BROKER_ISSUER" to variable "BROKER_ISSUER"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='49423_TEST']/../COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='49423_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='49423_TEST']/../BROKER_TICKER" to variable "BROKER_TICKER1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='49423_TEST']/../TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='49423_TEST']/../BROKER_ISSUER" to variable "BROKER_ISSUER1"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('15972_TEST','49423_TEST','BFI_TEST')AND end_tms IS NULL );
    COMMIT
    """

  Scenario: TC1: Load Broker file load with all the fields mentioned in the requirement
  New Financial Institution for counterparty will be created along with its identifier, description and role in DMP.
  New Financial Institution for issuer will be created. Also, Relationship between counterparty and brokerissuer is created.

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I assign "600" to variable "workflow.max.polling.time"

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='2'
      """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against COUNTERPARTY_CODE
    Then I expect value of column "FINS_COUNTRPRTY_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNTRPRTY_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND INST_DESC = '${COUNTERPARTY_NAME}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND PREF_FINS_ID = '${COUNTERPARTY_CDE}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}') AND end_tms IS NULL)
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FINS_ISSR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_ISSR_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND INST_DESC = '${COUNTERPARTY_NAME}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
        """

#    Check BROKER_ISSUER field from BRS file stored in FINS_ID olumn in FIID Table against FINS_ID_CTXT_TYP = 'BRSISSRID'
    Then I expect value of column "FIID_ISSRID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_ISSRID_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER}')
        AND FINS_ID = '${BROKER_ISSUER}'
        AND FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
        """

    #   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against COUNTERPARTY_CODE
    Then I expect value of column "FINS_COUNTRPRTY_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNTRPRTY_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME1}'
        AND INST_DESC = '${COUNTERPARTY_NAME1}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND PREF_FINS_ID = '${COUNTERPARTY_CDE1}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE1}') AND end_tms IS NULL)
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FINS_ISSR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_ISSR_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME1}'
        AND INST_DESC = '${COUNTERPARTY_NAME1}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER1}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${BROKER_ISSUER1}') AND end_tms IS NULL)
        """

#    Check BROKER_ISSUER field from BRS file stored in FINS_ID olumn in FIID Table against FINS_ID_CTXT_TYP = 'BRSISSRID'
    Then I expect value of column "FIID_ISSRID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_ISSRID_COUNT FROM FT_T_FIID
        WHERE FINS_ID = '${BROKER_ISSUER1}'
        AND FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND end_tms IS NULL
        """

#   Check COUNTERPARTY_CODE field from BRS file stored in FINS_ID olumn in FIID Table against FINS_ID_CTXT_TYP = 'BRSCNTCDE'
    Then I expect value of column "FIID_CNTCDE_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FIID_CNTCDE_COUNT FROM FT_T_FIID
        WHERE FINS_ID IN ('${COUNTERPARTY_CDE}','${COUNTERPARTY_CDE1}')
        AND FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND end_tms IS NULL
        """

#   Check BROKER_TICKER field from BRS file stored in FINS_ID olumn in FIID Table against FINS_ID_CTXT_TYP = 'BRSBROKRTICKR'
    Then I expect value of column "FIID_BROKRTICKR_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FIID_BROKRTICKR_COUNT FROM FT_T_FIID
        WHERE FINS_ID IN ('${BROKER_TICKER}','${BROKER_TICKER1}')
        AND FINS_ID_CTXT_TYP = 'BRSBROKRTICKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
         AND end_tms IS NULL
        """

#    Check TRD_COUNTERPARTY  field from BRS file stored in FINS_ID olumn in FIID Table against FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
    Then I expect value of column "FIID_TRDCNTCDE_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FIID_TRDCNTCDE_COUNT FROM FT_T_FIID
        WHERE FINS_ID IN ('${TRD_COUNTERPARTY}','${TRD_COUNTERPARTY1}')
        AND FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND end_tms IS NULL
        """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FIDE Table
    Then I expect value of column "FIDE_CNTCDE_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FIDE_CNTCDE_COUNT FROM FT_T_FIDE
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${COUNTERPARTY_CDE}','${COUNTERPARTY_CDE1}') AND end_tms IS NULL)
        AND INST_DESC IN ('${COUNTERPARTY_NAME}','${COUNTERPARTY_NAME1}')
        AND INST_NME IN ('${COUNTERPARTY_NAME}','${COUNTERPARTY_NAME1}')
        AND DATA_SRC_ID = 'BRS'
        """

#   Check BROKER_TYPE  field from BRS file gets its decoded value from IDMV/EDMV and stored in FINSRL_TYP column in FT_T_FINR Table
    Then I expect value of column "FINR_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${COUNTERPARTY_CDE}','${COUNTERPARTY_CDE1}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'BROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

#  Links two Financial Institutions BROKER_ISSUER and COUNTERPARTY_NAME
    Then I expect value of column "FFRL_COUNT" in the below SQL query equals to "2":
        """
        SELECT COUNT(*) AS FFRL_COUNT FROM FT_T_FFRL
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${COUNTERPARTY_CDE}','${COUNTERPARTY_CDE1}') AND end_tms IS NULL)
        AND PRNT_INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN ('${BROKER_ISSUER}','${BROKER_ISSUER1}') AND end_tms IS NULL)
        AND REL_TYP = 'PRIMBRKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory