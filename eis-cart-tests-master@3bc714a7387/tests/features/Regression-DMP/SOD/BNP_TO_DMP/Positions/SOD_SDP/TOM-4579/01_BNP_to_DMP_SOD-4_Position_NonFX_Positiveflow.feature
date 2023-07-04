# TOM-4579
# SOD-4_PositionNonFX : BNP to DMP Position Non FX Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-1225
# Current Ticket : https://jira.intranet.asia/browse/TOM-4579
# Requirement Link : https://collaborate.intranet.asia/display/TOM/SOD+Flows%3A+SOD+Positions+for+Reconciliation

@gc_interface_positions
@dmp_regression_unittest
@01_tom_4579_bnp_dmp_sod4_positions_nfx
Feature: SOD-4 Position NonFX Interface - Positive Flow Validation

  These test cases validate the BNP Position inbound file.

  Below Scenarios are handled as part of this feature :
  1.Verify that position file(SDP) is processed successfully.
  2.Validation for mandatory fields are mapped correctly in DMP post BNP data load
  3.Validation for other fields as per requirement

  Scenario: Load BNP NON FX Positions to DMP

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_SDP/TOM-4579" to variable "testdata.path"
    And I assign "ESISODP_SDP_positive_data.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_SDP_STOCK_template.out" to variable "INPUT_FILE_TEMPLATE"
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

    And I execute below query and extract values of "INSTR_ID_STOCK" column into incremental variables
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
    WHERE rownum <= 2
    """

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_TEMPLATE}" with below codes from location "${testdata.path}"
      |  |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |

    #processing the SOD-4_NONFX file
    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify NONLATAM records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario: Extract the field values of row 2 (LONG_SHORT_IND is L) from inbound file and store it into variables

    Then I extract below values for row 2 from PSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | INSTR_ID       | VAR_INSTR_ID       |
      | ACCT_ID        | VAR_ACCT_ID        |
      | NOMINAL        | VAR_NOMINAL        |
      | VALN_DATE      | VAR_VALN_DATE      |
      | ACCRUED_INC_L  | VAR_ACCRUED_INC_L  |
      | PFOLIO_CCY     | VAR_PFOLIO_CCY     |
      | VALUATION_P    | VAR_VALUATION_P    |
      | ACCRUED_INC_P  | VAR_ACCRUED_INC_P  |
      | VALUATION_L    | VAR_VALUATION_L    |
      | ORIG_QUANTITY  | VAR_ORIG_QUANTITY  |
      | ISSUE_CCY      | VAR_ISSUE_CCY      |
      | INQUIRY_BASIS  | VAR_INQUIRY_BASIS  |
      | ASSET_TYPE     | VAR_ASSET_TYPE     |
      | LONG_SHORT_IND | VAR_LONG_SHORT_IND |
      | RUN_DATE       | VAR_RUN_DATE       |
      | BALANCE_TYPE   | VAR_BALANCE_TYPE   |
      | PRICE_L        | VAR_PRICE_L        |

    And I execute below query and extract values of "BALH_OID" into same variables
    """
    SELECT BALH_OID AS BALH_OID
    FROM FT_T_BALH
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_INSTR_ID}' AND ID_CTXT_TYP='BNPLSTID')
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """

  Scenario Outline: SOD-4 NON FX Feed Validations for <Column> when ACCRUED_INC_P and ACCRUED_INC_L is available and LONG_SHORT_IND is L

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """
    Examples: Inbound file to DMP field mapping validation
      | Column              | Query                                                                                                                                                                                                                                                                           |
      | INSTR_ID_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INSTR_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ISID ISID ON BALH.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID = '${VAR_INSTR_ID}' AND BALH.BALH_OID ='${BALH_OID}'                                               |
      | ACCT_ID_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ACID ACID ON BALH.ACCT_ID = ACID.ACCT_ID WHERE ACID.ACCT_ALT_ID = '${VAR_ACCT_ID}' AND BALH.BALH_OID ='${BALH_OID}' AND ACID.ACCT_ID_CTXT_TYP ='BNPPRTID'        |
      | NOMINAL_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NOMINAL_CHECK FROM FT_T_BALH WHERE NOM_VAL_CAMT = '${VAR_NOMINAL}' AND BALH_OID ='${BALH_OID}'                                                                                                                     |
      | VALN_DATE_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALN_DATE_CHECK FROM FT_T_BALH WHERE AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD') AND BALH_OID ='${BALH_OID}'                                                                                             |
      | ACCRUED_INC_L_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_INC_ACCR_CAMT  = '${VAR_ACCRUED_INC_L}' AND BALH_OID ='${BALH_OID}'                                                                                            |
      | PFOLIO_CCY_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PFOLIO_CCY_CHECK FROM FT_T_BALH WHERE ENT_PROC_CURR_CDE  = '${VAR_PFOLIO_CCY}' AND BKPG_CURR_CDE = '${VAR_PFOLIO_CCY}' AND BALH_OID ='${BALH_OID}'                                                                 |
      | VALUATION_P_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_MKT_CAMT  = (CASE WHEN ${VAR_ACCRUED_INC_P} IS NOT NULL THEN (${VAR_VALUATION_P}-${VAR_ACCRUED_INC_P}) ELSE ${VAR_VALUATION_P} END) AND BALH_OID ='${BALH_OID}'   |
      | ACCRUED_INC_P_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_INC_ACCR_CAMT  = '${VAR_ACCRUED_INC_P}' AND BALH_OID ='${BALH_OID}'                                                                                             |
      | VALUATION_L_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_MKT_CAMT  = (CASE WHEN ${VAR_ACCRUED_INC_L} IS NOT NULL THEN (${VAR_VALUATION_L}-${VAR_ACCRUED_INC_L}) ELSE ${VAR_VALUATION_L} END)  AND BALH_OID ='${BALH_OID}' |
      | ORIG_QUANTITY_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ORIG_QUANTITY_CHECK FROM FT_T_BALH WHERE QTY_CQTY  = '${VAR_ORIG_QUANTITY}' AND BALH_OID ='${BALH_OID}'                                                                                                            |
      | ISSUE_CCY_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISSUE_CCY_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_CDE  = '${VAR_ISSUE_CCY}' AND BALH_OID ='${BALH_OID}'                                                                                                              |
      | INQUIRY_BASIS_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INQUIRY_BASIS_CHECK FROM FT_T_BALH WHERE RQSTR_ID  = (CASE WHEN '${VAR_INQUIRY_BASIS}' = '10' THEN 'SOD' ELSE 'EOD' END) AND BALH_OID ='${BALH_OID}'                                                               |
      | ORG_ID_CHECK        | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ORG_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ACID ACID ON BALH.ACCT_ID = ACID.ACCT_ID WHERE BALH.ORG_ID = ACID.ORG_ID AND BALH_OID ='${BALH_OID}' AND ACID.ACCT_ID_CTXT_TYP ='BNPPRTID'                        |
      | BK_ID_CHECK         | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BK_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ACID ACID ON BALH.ACCT_ID = ACID.ACCT_ID WHERE BALH.BK_ID = ACID.BK_ID AND BALH_OID ='${BALH_OID}' AND ACID.ACCT_ID_CTXT_TYP ='BNPPRTID'                           |
      | LDGR_ID_L_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LDGR_ID_L_CHECK FROM FT_T_BALH WHERE LDGR_ID  =(CASE WHEN '${VAR_LONG_SHORT_IND}' = 'L' THEN '0020' ELSE '0040' END) AND BALH_OID ='${BALH_OID}'                                                                   |
      | PRIN_INC_IND_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PRIN_INC_IND_CHECK FROM FT_T_BALH WHERE PRIN_INC_IND  ='B' AND BALH_OID ='${BALH_OID}'                                                                                                                             |
      | RUN_DATE_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS RUN_DATE_CHECK FROM FT_T_BALH WHERE ADJST_TMS  = TO_DATE('${VAR_RUN_DATE}','YYYY-MON-DD') AND BALH_OID ='${BALH_OID}'                                                                                              |
      | BALANCE_TYPE_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BALANCE_TYPE_CHECK FROM FT_T_BALH WHERE HST_REAS_TYP  = '${VAR_BALANCE_TYPE}' AND BALH_OID ='${BALH_OID}'                                                                                                          |
      | PRICE_L_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PRICE_L_CHECK FROM FT_T_BHST WHERE STAT_VAL_CAMT  ='${VAR_PRICE_L}' AND STAT_DEF_ID = 'BNPPRICE' AND BALH_OID ='${BALH_OID}'                                                                                       |

  Scenario: Extract the field values of row 3 (LONG_SHORT_IND is S) from inbound file and store it into variables

    Then I extract below values for row 3 from PSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | INSTR_ID       | VAR_INSTR_ID       |
      | ACCT_ID        | VAR_ACCT_ID        |
      | VALN_DATE      | VAR_VALN_DATE      |
      | ACCRUED_INC_L  | VAR_ACCRUED_INC_L  |
      | VALUATION_P    | VAR_VALUATION_P    |
      | ACCRUED_INC_P  | VAR_ACCRUED_INC_P  |
      | VALUATION_L    | VAR_VALUATION_L    |
      | LONG_SHORT_IND | VAR_LONG_SHORT_IND |

    And I execute below query and extract values of "BALH_OID" into same variables
    """
    SELECT BALH_OID AS BALH_OID
    FROM FT_T_BALH
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_INSTR_ID}' AND ID_CTXT_TYP='BNPLSTID')
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """

  Scenario Outline: SOD-4 NON FX Feed Validations for <Column> when ACCRUED_INC_P and ACCRUED_INC_L is NULL and LONG_SHORT_IND is S

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """
    Examples: Inbound file to DMP field mapping validation
      | Column              | Query                                                                                                                                                                                                                                                                           |
      | VALUATION_P_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_MKT_CAMT  = (CASE WHEN ${VAR_ACCRUED_INC_P} IS NOT NULL THEN (${VAR_VALUATION_P}-${VAR_ACCRUED_INC_P}) ELSE ${VAR_VALUATION_P} END) AND BALH_OID ='${BALH_OID}'   |
      | VALUATION_L_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_MKT_CAMT  = (CASE WHEN ${VAR_ACCRUED_INC_L} IS NOT NULL THEN (${VAR_VALUATION_L}-${VAR_ACCRUED_INC_L}) ELSE ${VAR_VALUATION_L} END)  AND BALH_OID ='${BALH_OID}' |
      | LDGR_ID_L_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LDGR_ID_L_CHECK FROM FT_T_BALH WHERE LDGR_ID  =(CASE WHEN '${VAR_LONG_SHORT_IND}' = 'L' THEN '0020' ELSE '0040' END) AND BALH_OID ='${BALH_OID}'                                                                   |
      | ACCRUED_INC_L_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_INC_ACCR_CAMT IS NULL AND BALH_OID ='${BALH_OID}'                                                                                                              |
      | ACCRUED_INC_P_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_INC_ACCR_CAMT IS NULL AND BALH_OID ='${BALH_OID}'                                                                                                               |