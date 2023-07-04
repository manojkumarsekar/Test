#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty @gc_interface_issuer
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3873 @tw_broker_update_issuer @tom_4094
Feature: Create Broker issuer from broker.xml and update using issuer.xml

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0004_Broker_Update_Issuer.xml" to variable "INPUT_FILENAME_BROKER"
    And I assign "0004_issuer_Update.xml" to variable "INPUT_FILENAME_ISSUER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_BROKER}" with tagName "COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_BROKER}" with tagName "COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_BROKER}" with tagName "BROKER_TICKER" to variable "BROKER_TICKER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_BROKER}" with tagName "TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_BROKER}" with tagName "BROKER_ISSUER" to variable "BROKER_ISSUER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_ISSUER}" with tagName "LONG_NAME" to variable "ISSUER_LONG_NAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_ISSUER}" with tagName "NAME" to variable "ISSUER_NAME"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('C87381_TEST','3001_TEST')AND end_tms IS NULL );
    COMMIT
    """

  Scenario: TC1: Load Broker file with Broker_issuer and Load issuer file to update this issuer information
  Expected Result: Financial institution for issuer should get updated

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BROKER} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BROKER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY  |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
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
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
    AND INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${BROKER_ISSUER}') AND end_tms IS NULL)
    """

#   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FIID_ISSR_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FIID_ISSR_COUNT
    FROM ft_t_FIID where INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${BROKER_ISSUER}') )
    AND end_tms IS NULL
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_ISSUER} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_ISSUER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER        |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
    """

    #   Check COUNTERPARTY_NAME field from BRS file stored in INST_NME and INST_DESC desc column in FINS Table against BROKER_ISSUER
    Then I expect value of column "FIID_ISSR_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FIID_ISSR_COUNT
    FROM ft_t_FIID where INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${BROKER_ISSUER}') )
    AND end_tms IS NULL
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
    WHERE INST_NME = '${ISSUER_NAME}'
    AND INST_DESC = '${ISSUER_LONG_NAME}'
    AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
    AND PREF_FINS_ID = '${BROKER_ISSUER}'
    AND DATA_SRC_ID = 'BRS'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
    AND INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${BROKER_ISSUER}') AND end_tms IS NULL)
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BROKER} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BROKER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY  |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
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
    WHERE INST_NME = '${ISSUER_NAME}'
    AND INST_DESC = '${ISSUER_LONG_NAME}'
    AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
    AND PREF_FINS_ID = '${BROKER_ISSUER}'
    AND DATA_SRC_ID = 'BRS'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_ISSUER'
     AND INST_MNEM IN (select INST_MNEM from ft_t_FIID where FINS_ID IN ('${BROKER_ISSUER}') AND end_tms IS NULL)
    """