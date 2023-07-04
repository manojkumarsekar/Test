#https://jira.intranet.asia/browse/TOM-1754
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=31134993

@gc_interface_exchange_rates
@dmp_regression_unittest
@0101_exchange_rates_bnp_to_dmp
Feature: Inbound Exchange Rates Interface Testing (R3.IN.NF02 BNP to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Process BNP Exchange Rates to DMP (NF02): Data Preparation

    And I assign "tests/test-data/dmp-interfaces/R3_IN_NF02_BNP_TO_DMP" to variable "testdata.path"

    Given I execute below query and extract values of "FX_TMS_TEMP" into same variables
      """
      SELECT TO_CHAR(MAX(FX_TMS),'YYYY-MON-DD') AS FX_TMS_TEMP FROM FT_T_FXRT WHERE SRCE_CURR_CDE='GBP' AND TRGT_CURR_CDE ='USD'
      """

      #Input file will be created from template by replacing FX_TMS variable with latest date+1
    And I modify date "${FX_TMS_TEMP}" with "+1d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "FX_TMS"

    Given I assign "ESISODP_EXR_Test_1.out" to variable "INPUT_FILENAME"
    And I assign "ESISODP_EXR_Test_Template.out" to variable "INPUT_TEMPLATENAME"

      #FX_TMS variable will be replaced in the file, hence no more additional codes are required
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

  Scenario: TC_2: Process BNP Exchange Rates to DMP (NF02): Data Loading

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER       |
      | FILE_PATTERN  | ESISODP_EXR_*.out            |
      | MESSAGE_TYPE  | EIS_MT_BNP_EOD_EXCHANGE_RATE |

  Scenario: TC_3: Process BNP Exchange Rates to DMP (NF02): Verifications

      #|ColumnName|Variable|
    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | FROM_CCY  | VAR_FROM_CCY  |
      | TO_CCY    | VAR_TO_CCY    |
      | TYPE      | VAR_TYPE      |
      | RATE      | VAR_RATE      |
      | SOURCE_ID | VAR_SOURCE_ID |

    Then I expect value of column "FX_RATE_LOAD_CHECK" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FX_RATE_LOAD_CHECK
        FROM FT_T_FXRT
        WHERE SRCE_CURR_CDE = '${VAR_FROM_CCY}'
        AND TRGT_CURR_CDE = '${VAR_TO_CCY}'
        AND FX_TYP = '${VAR_TYPE}'
        AND TO_CHAR(FX_TMS,'YYYY-MON-DD') = '${FX_TMS}'
        AND FX_CRTE = '${VAR_RATE}'
        AND FX_SRCE_TYP = '${VAR_SOURCE_ID}'
        AND LAST_CHG_USR_ID = 'EIS_MT_BNP_EOD_EXCHANGE_RATE'
        AND DATA_STAT_TYP = 'ACTIVE'
        AND DATA_SRC_ID = 'BNP'
        """

  Scenario: TC_4: Process BNP Exchange Rates to DMP (NF02) : Exception Verification in FT_T_NTEL

    Given I assign "ESISODP_EXR_Test_Exception_1.out" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/template" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER       |
      | FILE_PATTERN  | ESISODP_EXR_*.out            |
      | MESSAGE_TYPE  | EIS_MT_BNP_EOD_EXCHANGE_RATE |

    Given I assign below value to variable "SQL_QUERY"
        """
        SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}' AND
        TASK_CMPLTD_CNT > 0
        """

    And I execute query "${SQL_QUERY}" and extract values of "JOB_ID" into same variables

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
          ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
          AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.NOTFCN_ID=60001
      AND NTEL.PARM_VAL_TXT LIKE 'User defined Error thrown! . Cannot process the record as one or more required fields ((SOURCE_ID, FROM_CCY, TO_CCY, TYPE,FX_DATE,RATE) are null'
      AND NTEL.CHAR_VAL_TXT LIKE 'Missing Data Exception:- User defined Error thrown! . Cannot process the record as one or more required fields ((SOURCE_ID, FROM_CCY, TO_CCY, TYPE,FX_DATE,RATE) are null'
      """