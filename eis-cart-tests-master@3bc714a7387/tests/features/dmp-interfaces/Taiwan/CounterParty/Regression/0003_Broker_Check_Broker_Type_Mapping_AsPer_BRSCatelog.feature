#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4094

@gc_interface_counterparty
@dmp_regression_unittest
@dmp_taiwan
@tom_3873 @tw_broker_broker_type @tom_4094
Feature: Test the counterparty file from BRS for all the different broker_Type in interface catelog

  Scenario: TC0: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"
    And I assign "0003_Broker_Check_Broker_Type_Mapping_AsPer_BRSCatelog.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2000_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE1"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2001_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE2"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2002_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE3"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2003_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE4"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2004_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE5"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2005_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE6"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2006_Test']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE7"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2007_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE8"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2008_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE9"
    And I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUNTERPARTY//COUNTERPARTY_CODE[text()='2009_TEST']/../COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE10"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('C873351_TEST','2000_TEST','2001_TEST','2002_TEST','2003_TEST','2004_TEST','2005_TEST','2006_TEST','2007_TEST','2008_TEST','2009_TEST')AND end_tms IS NULL );
    COMMIT
    """

#  EISTOMTEST-3969
  Scenario: TC1: Load Broker file with all the broker_type mentioned in BRS catelog file
  New Financial Institution for counterparty will be created along with its identifier, description and role in DMP.
  Expected Result:FINSRL_TYP field in FINR table should populated with the INTRNL_DMN_VAL_TXT field value from IDMV table

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
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='10'
      """

#  Check BROKER_TYPE  field from BRS file gets its decoded value from IDMV/EDMV and stored in FINSRL_TYP column in FT_T_FINR Table
    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE1}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'BROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE2}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'CUSTDIAN'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE3}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'DEALER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """
    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE4}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'BANK'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE5}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'CUSTOMER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE6}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'SUBACCT'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE7}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'EXBROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE8}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'PRTFOLIO'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE9}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'CLIENT'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

    And I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE10}') AND end_tms IS NULL)
        AND FINSRL_TYP = 'TRAGENT'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory