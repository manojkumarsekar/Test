#https://jira.intranet.asia/browse/TOM-3680
#https://jira.intranet.asia/browse/TOM-4685 - test Chinese characters loaded properly and GSDM filtering applied

@gc_interface_securities
@dmp_regression_unittest
@dmp_taiwan
@tom_3680 @tom_4685
Feature: Verify CMoney data set up properly in database

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CMoney" to variable "testdata.path"
    And I assign "001_New_Security.csv" to variable "INPUT_FILENAME"

    And I execute below query to "Setup new dummy security in DMP"
    """
    ${testdata.path}/sql/CLEAR_DUMMY_DATA.sql;
    ${testdata.path}/sql/DUMMY_ISSU_ISID_FRIP_SETUP.sql
    """

  Scenario: TC_1: Load CMoney Security File records which are not present in db i.e. new Security is coming in file
  Expected Result:
  1) File should load successfully
  2) Verify that both records have been filtered since (1) has no ISIN or GretaID and (2) has an ISIN unknown to DMP

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      AND TASK_SUCCESS_CNT ='0'
      AND TASK_FILTERED_CNT = '2'
      """

  Scenario: TC_2: Exception should raised if Gretai ID is different in BRS and CMoney data

    Given I assign "002_Gretai_ID_Mismatch.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CMoney" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  # Check if NTEL has OPEN Notification for 60001
    Then I expect value of column "NTEL_VALID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_VALID_COUNT FROM FT_T_NTEL
        WHERE NOTFCN_STAT_TYP = 'OPEN'
        AND NOTFCN_ID = 60001
        AND MSG_SEVERITY_CDE = 40
        AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
        AND PARM_VAL_TXT LIKE '%User defined Error thrown! . Error: Mismatch between BRS Gretai ID in DMP and Gretai ID received from CMoney for ISIN -%'
      """

  Scenario: TC_3: Verify ISMC data set up for value of field - Fund Share Outstanding and ISCL set up for Sec Type

    And I expect value of column "ISMC_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISMC_COUNT FROM FT_T_ISMC
        WHERE CAPITAL_TYP = 'CMFSO'
        AND CAP_SEC_CQTY = '15099929.547'
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
        AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TS3680000006' AND ID_CTXT_TYP = 'ISIN'
        AND END_TMS IS NULL)
      """

    Then I expect value of column "ISCL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISCL_COUNT FROM FT_T_ISCL
        WHERE INDUS_CL_SET_ID = 'CMSECTYP'
        AND CL_VALUE = 'DomFunds'
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
        AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TS3680000006' AND ID_CTXT_TYP = 'ISIN'
        AND END_TMS IS NULL)
      """

  Scenario: TC_4: FINS and ISCL data should get linked properly to existing security data

    Given I assign "003_FINS_ISCL.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CMoney" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "FIID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS FIID_COUNT FROM FT_T_FIID
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM  FT_T_FINS WHERE INST_NME = 'TEST3680' )
        AND FINS_ID_CTXT_TYP IN ('ISSTICKER','UNIBUSNUM')
        AND FINS_ID IN ('YU52AC', '47224065' )
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
      """

    Then I expect value of column "FIDE_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS FIDE_COUNT FROM FT_T_FIDE
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM  FT_T_FINS WHERE INST_NME = 'TEST3680' )
        AND NLS_CDE = 'CHINESEM'
        AND DESC_USAGE_TYP = 'PRIMARY'
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
        AND INST_NME IS NOT NULL
        AND INST_DESC IS NOT NULL
      """
    Then I expect value of column "FIID_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS FIID_COUNT FROM FT_T_FIID
        WHERE INST_MNEM IN (SELECT INST_MNEM FROM  FT_T_FRIP WHERE INSTR_ID IN (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'B903WN' AND ID_CTXT_TYP = 'RPN' AND END_TMS IS NULL) AND END_TMS IS NULL )
        AND FINS_ID_CTXT_TYP IN ('UNIBUSNUM')
        AND FINS_ID IN ('TEST_4906' )
        AND DATA_SRC_ID = 'CMONEY'
        AND END_TMS IS NULL
      """