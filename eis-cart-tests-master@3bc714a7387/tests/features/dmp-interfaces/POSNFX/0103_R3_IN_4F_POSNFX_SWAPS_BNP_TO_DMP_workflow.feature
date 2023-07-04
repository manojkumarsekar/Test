#https://collaborate.intranet.asia/pages/viewpage.action?pageId=20611091
#https://jira.intranet.asia/browse/TOM-1359

@gc_interface_positions
@dmp_regression_unittest
@dmp_pos_nfx @0103_pos_nfx_bnp_dmp
Feature: Inbound EOD Position NonFX Interface Testing (R3.IN.4F BNP to DMP) - SWAPS

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_11: Process BNP NON FX Positions to DMP (4F) : SWAPS Data Preparation

    Given I assign "ESISODP_SDP_STK_SWAP.out" to variable "INPUT_FILENAME"
    And I assign "ESISODP_SDP_STK_SWAP_Template.out" to variable "INPUT_TEMPLATENAME"

    And I assign "tests/test-data/dmp-interfaces/R3_IN_4F_POSNFX_BNP_TO_DMP" to variable "testdata.path"

    #2nd Row is Payable (SHORT)
    Given I extract below values for row 2 from PSV file "${INPUT_TEMPLATENAME}" in local folder "${testdata.path}/template" and assign to variables:
      | ACCT_ID  | VAR_ACCT_ID    |
      | INSTR_ID | S_VAR_INSTR_ID |

    #3rd Row is Receivable (LONG)
    Given I extract below values for row 3 from PSV file "${INPUT_TEMPLATENAME}" in local folder "${testdata.path}/template" and assign to variables:
      | INSTR_ID | L_VAR_INSTR_ID |

    And I execute below query and extract values of "ACCT_ID" into same variables
      """
      SELECT * FROM FT_T_ACID
      WHERE ACCT_ID_CTXT_TYP='BNPPRTID'
      AND ACCT_ALT_ID = '${VAR_ACCT_ID}'
      """

    And I execute below query and extract values of "S_VAR_INSTR_ID" into same variables
      """
      SELECT INSTR_ID AS S_VAR_INSTR_ID FROM FT_T_ISID
      WHERE ID_CTXT_TYP='BNPLSTID' AND ISS_ID='${S_VAR_INSTR_ID}'AND END_TMS IS NULL
      """

    And I execute below query and extract values of "L_VAR_INSTR_ID" into same variables
      """
      SELECT INSTR_ID AS L_VAR_INSTR_ID FROM FT_T_ISID
      WHERE ID_CTXT_TYP='BNPLSTID' AND ISS_ID='${L_VAR_INSTR_ID}'AND END_TMS IS NULL
      """

    And I execute below query and extract values of "AS_OF_TMS_TEMP;ADJST_TMS_TEMP" into same variables
      """
      WITH TBL1
      AS(
          SELECT TO_CHAR(MIN(AS_OF_TMS),'YYYY-MON-DD') AS AS_OF_TMS, TO_CHAR(MIN(ADJST_TMS),'YYYY-MON-DD') AS ADJST_TMS FROM FT_T_BALH
          WHERE ACCT_ID = '${ACCT_ID}'
          AND INSTR_ID IN ('${S_VAR_INSTR_ID}','${L_VAR_INSTR_ID}')
          GROUP BY ACCT_ID,INSTR_ID
        )SELECT MIN(AS_OF_TMS) AS AS_OF_TMS_TEMP,MIN(ADJST_TMS) AS ADJST_TMS_TEMP FROM TBL1
      """

    When I modify date "${AS_OF_TMS_TEMP}" with "-1d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "AS_OF_TMS"
    And I modify date "${ADJST_TMS_TEMP}" with "-1d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "ADJST_TMS"
    And I modify date "${AS_OF_TMS_TEMP}" with "-2d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "PRICE_DATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      |  |  |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

  Scenario: TC_12: Process BNP NON FX Positions to DMP (4F): SWAPS Data Loading

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER                |
      | FILE_PATTERN  | ESISODP_SDP_*.out                     |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

  Scenario Outline: TC_13: Process BNP NON FX Positions to DMP (4F): SWAPS DATA  - INTRNL ROWS Verifications

    Given I assign "ESISODP_SDP_STK_SWAP.out" to variable "INPUT_FILENAME"
    And I extract below values for row <DataRow> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ACCT_ID        | VAR_ACCT_ID        |
      | INSTR_ID       | VAR_INSTR_ID       |
      | VALN_DATE      | VAR_VALN_DATE      |
      | RUN_DATE       | VAR_RUN_DATE       |
      | NOMINAL        | VAR_NOMINAL        |
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
      | BALANCE_TYPE   | VAR_BALANCE_TYPE   |
      | PRICE_L        | VAR_PRICE_L        |

    And I execute below query and extract values of "ACCT_ID" into same variables
      """
      SELECT ACCT_ID FROM FT_T_ACID
      WHERE ACCT_ID_CTXT_TYP='BNPPRTID'
      AND ACCT_ALT_ID = '${VAR_ACCT_ID}'
      """

    And I execute below query and extract values of "INSTR_ID" into same variables
      """
      SELECT INSTR_ID FROM FT_T_ISID
      WHERE ID_CTXT_TYP='BNPLSTID' AND ISS_ID='${VAR_INSTR_ID}'AND END_TMS IS NULL
      """

    And I execute below query and extract values of "BALH_OID" into same variables
      """
      SELECT
          msgp.xref_tbl_row_oid as BALH_OID
      FROM
          ft_t_trid trid,
          ft_t_msgp msgp,
          ft_t_balh balh
      WHERE
          msgp.xref_tbl_typ = 'BALH' and balh.balh_oid = msgp.xref_tbl_row_oid
          AND   balh.strategy_id is null
          AND balh.rqstr_id = 'INTRNL'
          AND   trid.trn_id = msgp.trn_id
          AND   trid.main_entity_id like '${VAR_INSTR_ID}%'
          AND   trid.job_id IN (
              SELECT
                  job_id
              FROM
                  (
                      SELECT
                          job_id,
                          ROW_NUMBER() OVER(
                              PARTITION BY job_input_txt
                              ORDER BY
                                  job_start_tms DESC
                          ) r
                      FROM
                          ft_t_jblg
                      WHERE
                          job_input_txt LIKE '%${INPUT_FILENAME}'
                  )
              WHERE
                  r = 1
          )
      """

    Given I assign "${testdata.path}/queries" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | NOM_VAL_CAMT_CHECK             | ${SQL_QUERIES_DIR}/NOM_VAL_CAMT_CHECK.sql             |
      | LOCAL_CURR_INC_ACCR_CAMT_CHECK | ${SQL_QUERIES_DIR}/LOCAL_CURR_INC_ACCR_CAMT_CHECK.sql |
      | ENT_PROC_CURR_CDE_CHECK        | ${SQL_QUERIES_DIR}/ENT_PROC_CURR_CDE_CHECK.sql        |
      | BKPG_CURR_CDE_CHECK            | ${SQL_QUERIES_DIR}/BKPG_CURR_CDE_CHECK.sql            |
      | BKPG_CURR_MKT_CAMT_CHECK       | ${SQL_QUERIES_DIR}/BKPG_CURR_MKT_CAMT_CHECK.sql       |
      | BKPG_CURR_INC_ACCR_CAMT_CHECK  | ${SQL_QUERIES_DIR}/BKPG_CURR_INC_ACCR_CAMT_CHECK.sql  |
      | LOCAL_CURR_MKT_CAMT_CHECK      | ${SQL_QUERIES_DIR}/LOCAL_CURR_MKT_CAMT_CHECK.sql      |
      | QTY_CQTY_CHECK                 | ${SQL_QUERIES_DIR}/QTY_CQTY_CHECK.sql                 |
      | LOCAL_CURR_CDE_CHECK           | ${SQL_QUERIES_DIR}/LOCAL_CURR_CDE_CHECK.sql           |
      | CL_VALUE_CHECK                 | ${SQL_QUERIES_DIR}/CL_VALUE_CHECK.sql                 |
      | ORG_ID_CHECK                   | ${SQL_QUERIES_DIR}/ORG_ID_CHECK.sql                   |
      | BK_ID_CHECK                    | ${SQL_QUERIES_DIR}/BK_ID_CHECK.sql                    |
      | LDGR_ID_CHECK                  | ${SQL_QUERIES_DIR}/LDGR_ID_CHECK.sql                  |
      | PRIN_INC_IND_CHECK             | ${SQL_QUERIES_DIR}/PRIN_INC_IND_CHECK.sql             |
      | HST_REAS_TYP_CHECK             | ${SQL_QUERIES_DIR}/HST_REAS_TYP_CHECK.sql             |
      #|       STAT_VAL_CAMT_CHECK                             |       ${SQL_QUERIES_DIR}/STAT_VAL_CAMT_CHECK.sql                         |

    Examples:
      | Description       | DataRow |
      | Payable (SHORT)   | 2       |
      | Receivable (LONG) | 3       |

  Scenario: TC_14: Process BNP NON FX Positions to DMP (4F): SWAPS DATA  - SOD ROW Verifications

  There should be 2 INTRNL records and 1 SOD record should be created. SOD record should be created for LONG leg.

    Given I assign "ESISODP_SDP_STK_SWAP.out" to variable "INPUT_FILENAME"
    And I extract below values for row 3 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ACCT_ID        | VAR_ACCT_ID        |
      | INSTR_ID       | VAR_INSTR_ID       |
      | VALN_DATE      | VAR_VALN_DATE      |
      | RUN_DATE       | VAR_RUN_DATE       |
      | NOMINAL        | VAR_NOMINAL        |
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
      | BALANCE_TYPE   | VAR_BALANCE_TYPE   |
      | PRICE_L        | VAR_PRICE_L        |

    And I execute below query and extract values of "ACCT_ID" into same variables
      """
      SELECT ACCT_ID FROM FT_T_ACID
      WHERE ACCT_ID_CTXT_TYP='BNPPRTID'
      AND ACCT_ALT_ID = '${VAR_ACCT_ID}'
      """

    And I execute below query and extract values of "INSTR_ID" into same variables
      """
      SELECT INSTR_ID FROM FT_T_ISID
      WHERE ID_CTXT_TYP='BNPLSTID' AND ISS_ID='${VAR_INSTR_ID}'AND END_TMS IS NULL
      """

    Then I expect value of column "SOD_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS SOD_COUNT FROM FT_T_BALH
      WHERE TO_CHAR(AS_OF_TMS,'YYYY-MON-DD')='${VAR_VALN_DATE}'
      AND TO_CHAR(ADJST_TMS,'YYYY-MON-DD')='${VAR_RUN_DATE}'
      AND ACCT_ID='${ACCT_ID}'
      AND STRATEGY_ID IS NOT NULL
      AND RQSTR_ID = 'SOD'
      AND TO_CHAR(LAST_CHG_TMS,'DD-MON-YYYYHH24:MI:SS') >= TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS')
      """

    And I execute below query and extract values of "BALH_OID" into same variables
      """
      SELECT
          msgp.xref_tbl_row_oid as BALH_OID
      FROM
          ft_t_trid trid,
          ft_t_msgp msgp,
          ft_t_balh balh
      WHERE
          msgp.xref_tbl_typ = 'BALH' and balh.balh_oid = msgp.xref_tbl_row_oid
          AND   balh.strategy_id is not null
          AND   balh.rqstr_id = 'SOD'
          AND   trid.trn_id = msgp.trn_id
          AND   trid.main_entity_id like '${VAR_INSTR_ID}%'
          AND   trid.job_id IN (
              SELECT
                  job_id
              FROM
                  (
                      SELECT
                          job_id,
                          ROW_NUMBER() OVER(
                              PARTITION BY job_input_txt
                              ORDER BY
                                  job_start_tms DESC
                          ) r
                      FROM
                          ft_t_jblg
                      WHERE
                          job_input_txt LIKE '%${INPUT_FILENAME}'
                  )
              WHERE
                  r = 1
          )
      """

    Given I assign "${testdata.path}/queries" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | NOM_VAL_CAMT_CHECK             | ${SQL_QUERIES_DIR}/NOM_VAL_CAMT_CHECK.sql             |
      | LOCAL_CURR_INC_ACCR_CAMT_CHECK | ${SQL_QUERIES_DIR}/LOCAL_CURR_INC_ACCR_CAMT_CHECK.sql |
      | ENT_PROC_CURR_CDE_CHECK        | ${SQL_QUERIES_DIR}/ENT_PROC_CURR_CDE_CHECK.sql        |
      | BKPG_CURR_CDE_CHECK            | ${SQL_QUERIES_DIR}/BKPG_CURR_CDE_CHECK.sql            |
      | BKPG_CURR_INC_ACCR_CAMT_CHECK  | ${SQL_QUERIES_DIR}/BKPG_CURR_INC_ACCR_CAMT_CHECK.sql  |
      | QTY_CQTY_CHECK                 | ${SQL_QUERIES_DIR}/QTY_CQTY_CHECK.sql                 |
      | LOCAL_CURR_CDE_CHECK           | ${SQL_QUERIES_DIR}/LOCAL_CURR_CDE_CHECK.sql           |
      | CL_VALUE_CHECK                 | ${SQL_QUERIES_DIR}/CL_VALUE_CHECK.sql                 |
      | ORG_ID_CHECK                   | ${SQL_QUERIES_DIR}/ORG_ID_CHECK.sql                   |
      | BK_ID_CHECK                    | ${SQL_QUERIES_DIR}/BK_ID_CHECK.sql                    |
      | LDGR_ID_CHECK                  | ${SQL_QUERIES_DIR}/LDGR_ID_CHECK.sql                  |
      | PRIN_INC_IND_CHECK             | ${SQL_QUERIES_DIR}/PRIN_INC_IND_CHECK.sql             |
      | HST_REAS_TYP_CHECK             | ${SQL_QUERIES_DIR}/HST_REAS_TYP_CHECK.sql             |
      | LOCAL_CURR_MKT_CAMT_CHECK      | ${SQL_QUERIES_DIR}/SOD_LOCAL_CURR_MKT_CAMT_CHECK.sql  |
      | BKPG_CURR_MKT_CAMT_CHECK       | ${SQL_QUERIES_DIR}/SOD_BKPG_CURR_MKT_CAMT_CHECK.sql   |