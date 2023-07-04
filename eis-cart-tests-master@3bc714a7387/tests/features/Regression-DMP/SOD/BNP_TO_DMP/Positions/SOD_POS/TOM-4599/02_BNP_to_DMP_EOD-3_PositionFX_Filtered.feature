# Requirement Link: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14789845
# Parent Ticket: https://jira.intranet.asia/browse/TOM-3594
# Current Ticket: https://jira.intranet.asia/browse/TOM-4599

@gc_interface_positions
@dmp_regression_unittest
@02_tom_4599_bnp_dmp_eod3_positions_fx
Feature: SOD-3 Position FX Interface - Filtered Records

  Below Scenarios are handled as part of this feature:
  1. Validate the processing of test filter file
  2. Validate successful filtering of LATAM & Non-FX records

  Scenario: TC01: Load BNP FX Positions to DMP

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_POS/TOM-4599" to variable "testdata.path"
    And I assign "ESISODP_POS_FX_FILTER_FILE.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_POS_FX_TEMPLATE_FILE_FILTER.out" to variable "INPUT_TEMPLATE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "TEST_DATE_IN"
    And I generate value with date format "mmss" and assign to variable "DYNAMIC_VALUE"

    And I execute below query and extract values of "ACCT_ID_LATAM" into same variables
      """
    SELECT * FROM
    (    SELECT DISTINCT ACCT_ALT_ID AS ACCT_ID_LATAM
      FROM FT_T_ACID ACID
      INNER JOIN FT_T_ACST ACST
      ON ACID.ACCT_ID = ACST.ACCT_ID
      INNER JOIN FT_T_ACGU ACGU
      ON ACID.ACCT_ID = ACGU.ACCT_ID
      WHERE ACID.ACCT_ID_CTXT_TYP='BNPPRTID'
      AND ACID.END_TMS IS NULL
      AND ACGU.END_TMS IS NULL
      AND ACST.STAT_DEF_ID ='NPP'
      AND ACST.STAT_CHAR_VAL_TXT ='N'
      AND ACGU.GU_TYP='REGION'
      AND ACGU.GU_CNT =1
      AND ACGU.ACCT_GU_PURP_TYP ='POS_SEGR'
      AND ACGU.GU_ID = 'LATAM'
      ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 1
      """

    And I execute below query and extract values of "INSTR_ID_NONFX" into same variables
      """
      SELECT * FROM
    ( SELECT DISTINCT ISS_ID AS INSTR_ID_NONFX
      FROM FT_T_ISID ISID
      INNER JOIN FT_T_ISCL ISCL
      ON ISID.INSTR_ID = ISCL.INSTR_ID
      WHERE ISID.ID_CTXT_TYP='BNPLSTID'
      AND ISID.END_TMS IS NULL
      AND ISCL.END_TMS IS NULL
      AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
      AND ISCL.CL_VALUE = 'STOCK'
      ORDER BY DBMS_RANDOM.VALUE
       )
    WHERE rownum <= 1
      """

    And I execute below query and extract values of "INSTR_ID_FX" into same variables
      """
      SELECT * FROM
    ( SELECT DISTINCT ISS_ID AS INSTR_ID_FX
      FROM FT_T_ISID ISID
      INNER JOIN FT_T_ISCL ISCL
      ON ISID.INSTR_ID = ISCL.INSTR_ID
      WHERE ISID.ID_CTXT_TYP='BNPLSTID'
      AND ISID.END_TMS IS NULL
      AND ISCL.END_TMS IS NULL
      AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
      AND ISCL.CL_VALUE = 'FX'
      ORDER BY DBMS_RANDOM.VALUE
       )
    WHERE rownum <= 1
      """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_TEMPLATE_NAME}" with below codes from location "${testdata.path}"
      |  |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                 |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are NOT processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "0":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """
   #verify all the records are filtered successfully
    Then I expect value of column "FILTERED_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_FILTERED_CNT AS FILTERED_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """



