# TOM-4579
# SOD-4_PositionNonFX : BNP to DMP Position Non FX Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-1225
# Current Ticket : https://jira.intranet.asia/browse/TOM-4579
# Requirement Link : https://collaborate.intranet.asia/display/TOM/SOD+Flows%3A+SOD+Positions+for+Reconciliation

@gc_interface_positions
@dmp_regression_unittest
@02_tom_4579_bnp_dmp_sod4_positions_nfx
Feature: SOD-4 Position NonFX Interface - filter records

  Below Scenarios are handled as part of this feature:
  1. Validate that LATAM records are filetered in SOD-4 Position NonFX file processing
  2. Validate that Non Stock records are filetered in SOD-4 Position NonFX file processing


  Scenario: Load BNP NON FX Positions to DMP and validate the filtering criteria

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_SDP/TOM-4579" to variable "testdata.path"
    And I assign "ESISODP_SDP_filter_records.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_SDP_filter_template.out" to variable "INPUT_FILE_TEMPLATE"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "TEST_DATE_IN"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    And I execute below query and extract values of "ACCT_ID_NONLATAM" into same variables
    """
    SELECT * FROM
    (SELECT DISTINCT ACCT_ALT_ID AS ACCT_ID_NONLATAM
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
     AND ACGU.GU_ID = 'NONLATAM'
     ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 1
    """

    And I execute below query and extract values of "INSTR_ID_STOCK" into same variables
    """
    SELECT * FROM
    (SELECT DISTINCT ISS_ID AS INSTR_ID_STOCK
     FROM FT_T_ISID ISID
     INNER JOIN FT_T_ISCL ISCL
     ON ISID.INSTR_ID = ISCL.INSTR_ID
     WHERE ISID.ID_CTXT_TYP='BNPLSTID'
     AND ISID.END_TMS IS NULL
     AND ISCL.END_TMS IS NULL
     AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
     AND ISCL.CL_VALUE ='STOCK'
     ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 1
    """

    And I execute below query and extract values of "ACCT_ID_LATAM" into same variables
    """
    SELECT * FROM
    (SELECT DISTINCT ACCT_ALT_ID AS ACCT_ID_LATAM
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

    And I execute below query and extract values of "INSTR_ID_NONSTOCK" into same variables
    """
    SELECT * FROM
    (SELECT DISTINCT ISS_ID AS INSTR_ID_NONSTOCK
     FROM FT_T_ISID ISID
     INNER JOIN FT_T_ISCL ISCL
     ON ISID.INSTR_ID = ISCL.INSTR_ID
     WHERE ISID.ID_CTXT_TYP='BNPLSTID'
     AND ISID.END_TMS IS NULL
     AND ISCL.END_TMS IS NULL
     AND ISCL.INDUS_CL_SET_ID='BNPASTYP'
     AND ISCL.CL_VALUE ='FX'
     ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE rownum <= 1
    """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_TEMPLATE}" with below codes from location "${testdata.path}"
      |  |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify NO records should be processed
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "0":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

    #verify LATAM and NON Stock records are filtered while processing it in DMP
    Then I expect value of column "FILTERED_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_FILTERED_CNT AS FILTERED_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """
