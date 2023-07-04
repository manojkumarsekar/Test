# SOD-4_PositionNonFX : BNP to DMP Position Non FX Interface
# Parent Ticket : https://jira.intranet.asia/browse/TOM-1225
# Current Ticket : https://jira.intranet.asia/browse/TOM-4579
# Requirement Link : https://collaborate.intranet.asia/display/TOM/SOD+Flows%3A+SOD+Positions+for+Reconciliation

#Validation of 2 fields (VALUATION_P,VALUATION_L) is pending for merged record,need to check the logic

@gc_interface_positions
@dmp_regression_unittest
@04_tom_4579_bnp_dmp_sod4_positions_nfx
Feature: SOD-4 Position NonFX Interface - Positive Flow Validation for SWAPs

  A)In case of Swap there will be 2 instr_id (Payable and receivable) and their relation is defined in LINK_INSTR_ID column in security file.
  B)2 INTRNL and 1 SOD  record should be created when the position file is processed.

  Below Scenarios are handled as part of this feature:
  1. Validation for mandatory fields post BNP data load
  2. Validation for other fields as per requirement

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Positions/SOD_SDP/TOM-4579" to variable "testdata.path"
    And I assign "ESISODP_SDP_SWAP_positive_data.out" to variable "INPUT_FILE_NAME"
    And I assign "ESISODP_SDP_STOCK_SWAP_template.out" to variable "INPUT_FILE_TEMPLATE"
    And I assign "ESISODP_SEC_SWP_LOAD.out" to variable "INPUT_FILE_SEC"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "TEST_DATE_IN"

    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

  Scenario Outline: Clear existing data for the row <RowNum> in the security input file

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILE_SEC}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | CUSIP               | VAR_CUSIP               |
      | HIP_EXT2_ID         | VAR_HIP_EXT2_ID         |
      | BLOOMBERG_GLOBAL_ID | VAR_BLOOMBERG_GLOBAL_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"

    Examples:
      | RowNum |
      | 2      |
      | 3      |

  Scenario: Load BNP NON FX Positions to DMP

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

    And I extract below values for row 2 from PSV file "${INPUT_FILE_SEC}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID | VAR_INSTR_ID_PAY |

    And I extract below values for row 3 from PSV file "${INPUT_FILE_SEC}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID | VAR_INSTR_ID_RECEIEVE |

    When I create input file "${INPUT_FILE_NAME}" using template "${INPUT_FILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | INSTR_ID1 | ${VAR_INSTR_ID_PAY}      |
      | INSTR_ID2 | ${VAR_INSTR_ID_RECEIEVE} |

    When I create input file "${INPUT_FILE_PTF}" using template "${INPUT_TEMPLATE_PTF}" with below codes from location "${testdata.path}"
      |  |  |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILE_NAME} |
      | ${INPUT_FILE_SEC}  |

    #processing the security file as a pre-requisite
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILE_SEC}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    #processing the SOD-4_NONFX file
    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "2":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario Outline: Extract each field value of <RECORDTYPE> records from inbound File to Data-Table

    Then I extract below values for row <ROWNUM> from PSV file "${INPUT_FILE_NAME}" in local folder "${testdata.path}/testdata" with reference to "SOURCE_ID" column and assign to variables:
      | INSTR_ID       | VAR_INSTR_ID<ROWNUM>       |
      | ACCT_ID        | VAR_ACCT_ID                |
      | NOMINAL        | VAR_NOMINAL<ROWNUM>        |
      | VALN_DATE      | VAR_VALN_DATE              |
      | ACCRUED_INC_L  | VAR_ACCRUED_INC_L<ROWNUM>  |
      | PFOLIO_CCY     | VAR_PFOLIO_CCY<ROWNUM>     |
      | VALUATION_P    | VAR_VALUATION_P<ROWNUM>    |
      | ACCRUED_INC_P  | VAR_ACCRUED_INC_P<ROWNUM>  |
      | VALUATION_L    | VAR_VALUATION_L<ROWNUM>    |
      | ORIG_QUANTITY  | VAR_ORIG_QUANTITY<ROWNUM>  |
      | ISSUE_CCY      | VAR_ISSUE_CCY<ROWNUM>      |
      | INQUIRY_BASIS  | VAR_INQUIRY_BASIS<ROWNUM>  |
      | ASSET_TYPE     | VAR_ASSET_TYPE<ROWNUM>     |
      | LONG_SHORT_IND | VAR_LONG_SHORT_IND<ROWNUM> |
      | RUN_DATE       | VAR_RUN_DATE               |
      | BALANCE_TYPE   | VAR_BALANCE_TYPE<ROWNUM>   |
      | PRICE_L        | VAR_PRICE_L<ROWNUM>        |
      | BOOK_COST_L    | VAR_BOOK_COST_L<ROWNUM>    |

    Examples:
      | ROWNUM | RECORDTYPE |
      | 2      | PAY        |
      | 3      | RECEIVE    |

  Scenario: Verify that 3 entries are inserted in BALH table for pay,receive and merged leg and extract their respective BALH_OID

    Then I expect value of column "ROW_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS ROW_COUNT FROM FT_T_BALH
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID2}','${VAR_INSTR_ID3}') AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL)
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """

    And I execute below query and extract values of "BALH_OID_PAYLEG" into same variables
    """
    SELECT BALH_OID AS BALH_OID_PAYLEG
    FROM FT_T_BALH
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_INSTR_ID2}' AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL)
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND RQSTR_ID = 'INTRNL'
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """
    And I execute below query and extract values of "BALH_OID_RECIEVELEG" into same variables
    """
    SELECT BALH_OID AS BALH_OID_RECIEVELEG
    FROM FT_T_BALH
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_INSTR_ID3}' AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL)
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND RQSTR_ID ='INTRNL'
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """
    And I execute below query and extract values of "BALH_OID_MERGELEG" into same variables
    """
    SELECT BALH_OID AS BALH_OID_MERGELEG
    FROM FT_T_BALH
    WHERE INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${VAR_INSTR_ID3}' AND ID_CTXT_TYP='BNPLSTID' AND END_TMS IS NULL)
    AND ACCT_ID = (SELECT ACCT_ID FROM  FT_T_ACID  WHERE ACCT_ID_CTXT_TYP='BNPPRTID'  AND  ACCT_ALT_ID ='${VAR_ACCT_ID}')
    AND RQSTR_ID ='SOD'
    AND AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD')
    """

  Scenario Outline: SOD-4 NON FX Feed MERGED Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """`
    <Query>
    """
    Examples: Inbound file to DMP field mapping validation
      | Column              | Query                                                                                                                                                                                                                                                                                                |
      | INSTR_ID_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INSTR_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ISID ISID ON BALH.INSTR_ID = ISID.INSTR_ID WHERE ISID.ISS_ID = '${VAR_INSTR_ID3}' AND BALH.BALH_OID ='${BALH_OID_MERGELEG}'                                                          |
      | ACCT_ID_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCT_ID_CHECK FROM FT_T_BALH BALH INNER JOIN FT_T_ACID ACID ON BALH.ACCT_ID = ACID.ACCT_ID WHERE ACID.ACCT_ALT_ID = '${VAR_ACCT_ID}' AND BALH.BALH_OID ='${BALH_OID_MERGELEG}' AND ACID.ACCT_ID_CTXT_TYP ='BNPPRTID'                    |
      | VALN_DATE_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALN_DATE_CHECK FROM FT_T_BALH WHERE AS_OF_TMS = TO_DATE('${VAR_VALN_DATE}','YYYY-MON-DD') AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                         |
      | PFOLIO_CCY_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PFOLIO_CCY_CHECK FROM FT_T_BALH WHERE ENT_PROC_CURR_CDE  = '${VAR_PFOLIO_CCY3}' AND BKPG_CURR_CDE = '${VAR_PFOLIO_CCY3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                           |
     # | VALUATION_P_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_MKT_CAMT  = (('${VAR_VALUATION_P2}'-'${VAR_ACCRUED_INC_P3}')) AND BALH_OID ='${BALH_OID_MERGELEG}'                                     |
      | BALANCE_TYPE_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BALANCE_TYPE_CHECK FROM FT_T_BALH WHERE HST_REAS_TYP  = '${VAR_BALANCE_TYPE3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                                     |
      | LDGR_ID_L_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS LDGR_ID_L_CHECK FROM FT_T_BALH WHERE LDGR_ID  = (CASE WHEN '${VAR_LONG_SHORT_IND3}' = 'L' THEN '0020' ELSE '0040' END) AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                             |
     # | VALUATION_L_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS VALUATION_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_MKT_CAMT  = (('${VAR_VALUATION_L2}'-'${VAR_ACCRUED_INC_L3}')) AND BALH_OID ='${BALH_OID_MERGELEG}'                                    |
      | PRIN_INC_IND_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PRIN_INC_IND_CHECK FROM FT_T_BALH WHERE PRIN_INC_IND  ='B' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                                                         |
      | QTY_CQTY_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS QTY_CQTY_CHECK FROM FT_T_BALH WHERE QTY_CQTY  = (CASE WHEN '${VAR_ORIG_QUANTITY3}' IS NOT NULL THEN '${VAR_ORIG_QUANTITY3}' WHEN '${VAR_NOMINAL3}' IS NOT NULL THEN '${VAR_NOMINAL3}' ELSE '0' END)AND BALH_OID ='${BALH_OID_MERGELEG}' |
      | ISSUE_CCY_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISSUE_CCY_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_CDE  = '${VAR_ISSUE_CCY3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                                         |
      | RUN_DATE_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS RUN_DATE_CHECK FROM FT_T_BALH WHERE ADJST_TMS  = TO_DATE('${VAR_RUN_DATE}','YYYY-MON-DD') AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                          |
      | INQUIRY_BASIS_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INQUIRY_BASIS_CHECK FROM FT_T_BALH WHERE RQSTR_ID  = (CASE WHEN '${VAR_INQUIRY_BASIS3}' = '10' THEN 'SOD' ELSE 'EOD' END) AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                          |
      | NOMINAL_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NOMINAL_CHECK FROM FT_T_BALH WHERE NOM_VAL_CAMT = '${VAR_NOMINAL3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                                                |
      | ACCRUED_INC_L_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_INC_ACCR_CAMT  = '${VAR_ACCRUED_INC_L3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                       |
      | BOOK_COST_L_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BOOK_COST_L_CHECK FROM FT_T_BALH WHERE LOCAL_CURR_BOOK_VAL_CAMT = '${VAR_BOOK_COST_L3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                            |
      | ACCRUED_INC_P_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ACCRUED_INC_P_CHECK FROM FT_T_BALH WHERE BKPG_CURR_INC_ACCR_CAMT  = '${VAR_ACCRUED_INC_P3}' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                        |
      | PRICE_L_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PRICE_L_CHECK FROM FT_T_BHST WHERE STAT_VAL_CAMT  ='${VAR_PRICE_L3}' AND STAT_DEF_ID = 'BNPPRICE' AND BALH_OID ='${BALH_OID_MERGELEG}'                                                                                                  |
