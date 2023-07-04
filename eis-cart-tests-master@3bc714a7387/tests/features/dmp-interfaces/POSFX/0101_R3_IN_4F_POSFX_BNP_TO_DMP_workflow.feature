#https://collaborate.intranet.asia/pages/viewpage.action?pageId=14790745
#https://jira.intranet.asia/browse/TOM-1241

@gc_interface_positions
@dmp_regression_unittest
@dmp_pos_fx @0101_pos_fx_bnp_dmp
Feature: Inbound EOD Position FX Interface Testing (R3.IN.4F BNP to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario Outline: TC_1: Process BNP FX Positions to DMP (4F): "<InputFile>" Data Preparation

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"
    And I assign "<Template>" to variable "INPUT_TEMPLATENAME"

    And I assign "tests/test-data/dmp-interfaces/R3_IN_4F_POSFX_BNP_TO_DMP" to variable "testdata.path"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | TRAN_ID | DateTimeFormat:dHmsS |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Examples:
      | InputFile                              | Template                                      |
      | ESISODP_POS_VALID_DATA_1.out           | ESISODP_POS_VALID_Template.out                |
      | ESISODP_POS_VALID_DUPLICATE_ROWS_1.out | ESISODP_POS_VALID_DUPLICATE_ROWS_Template.out |

  Scenario: TC_2: Process BNP FX Positions to DMP (4F): Data Loading

    Then I send "Process Files Directory Asynchron" request with below template parameters with template "tests/test-data/dmp-interfaces/Process_Files/template/request.xmlt" and save the response to file "testout/dmp-interfaces/asyncResponse.xml"
      | BUSINESS_FEED  | EIS_BF_BNP_FIXEDHEADER               |
      | INPUT_DATA_DIR | /home/jbossadm/automatedtest/inbound |
      | FILE_PATTERN   | ESISODP_POS_*.out                    |
      | MESSAGE_TYPE   | EIS_MT_BNP_SOD_POSITIONFX_LATAM      |


    Then I extract a value from the XML file "testout/dmp-interfaces/asyncResponse.xml" using XPath query in file "tests/test-data/dmp-interfaces/Process_Files/template/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE
      TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
      JOB_INPUT_TXT LIKE '%ESISODP%.out' AND
      TASK_CMPLTD_CNT > 0
      """

  Scenario Outline: TC_3: Process BNP FX Positions to DMP (4F): "<InputFile>" Row <DataRow> Verifications
  Verifications related to FT_T_BALH table for LONG and SHORT legs

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"

    Given I extract below values for row <DataRow> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | TRAN_ID        | VAR_TRAN_ID        |
      | LONG_SHORT_IND | VAR_LONG_SHORT_IND |
      | INQUIRY_BASIS  | VAR_INQUIRY_BASIS  |
      | INSTR_ID       | VAR_INSTR_ID       |
      | ASSET_TYPE     | VAR_ASSET_TYPE     |
      | ACCT_ID        | VAR_ACCT_ID        |
      | VALUATION_L    | VAR_VALUATION_L    |
      | VALN_DATE      | VAR_VALN_DATE      |
      | RUN_DATE       | VAR_RUN_DATE       |
      | NOMINAL        | VAR_NOMINAL        |
      | ORIG_QUANTITY  | VAR_ORIG_QUANTITY  |
      | PFOLIO_CCY     | VAR_PFOLIO_CCY     |
      | ISSUE_CCY      | VAR_ISSUE_CCY      |
      | PRICE_L        | VAR_PRICE_L        |


    And I execute below query and extract values of "BALH_OID" into same variables
    """
    SELECT BALH_OID
    FROM FT_T_BALH BALH
      JOIN FT_T_ISID ISID
    ON BALH.INSTR_ID=ISID.INSTR_ID
    WHERE ISID.ISS_ID = '${VAR_TRAN_ID}'
    AND ISID.ID_CTXT_TYP='FXTRANID'
    AND LDGR_ID = (CASE WHEN '${VAR_LONG_SHORT_IND}' = 'L' THEN '0020' ELSE '0040' END)
    """

    Given I assign "${testdata.path}/queries" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | RQSTR_ID_CHECK            | ${SQL_QUERIES_DIR}/RQSTR_ID_CHECK.sql            |
      | CL_VALUE_CHECK            | ${SQL_QUERIES_DIR}/CL_VALUE_CHECK.sql            |
      | ISS_PART_TL_TYP_CHECK     | ${SQL_QUERIES_DIR}/ISS_PART_TL_TYP_CHECK.sql     |
      | ISS_ID_CHECK              | ${SQL_QUERIES_DIR}/ISS_ID_CHECK.sql              |
      | INSTR_ID_CHECK            | ${SQL_QUERIES_DIR}/INSTR_ID_CHECK.sql            |
      | ACCT_ID_CHECK             | ${SQL_QUERIES_DIR}/ACCT_ID_CHECK.sql             |
      | LOCAL_CURR_MKT_CAMT_CHECK | ${SQL_QUERIES_DIR}/LOCAL_CURR_MKT_CAMT_CHECK.sql |
      | AS_OF_TMS_CHECK           | ${SQL_QUERIES_DIR}/AS_OF_TMS_CHECK.sql           |
      | ADJST_TMS_CHECK           | ${SQL_QUERIES_DIR}/ADJST_TMS_CHECK.sql           |
      | ORG_ID_CHECK              | ${SQL_QUERIES_DIR}/ORG_ID_CHECK.sql              |
      | BK_ID_CHECK               | ${SQL_QUERIES_DIR}/BK_ID_CHECK.sql               |
      | PRIN_INC_IND_CHECK        | ${SQL_QUERIES_DIR}/PRIN_INC_IND_CHECK.sql        |
      | NOM_VAL_CAMT_CHECK        | ${SQL_QUERIES_DIR}/NOM_VAL_CAMT_CHECK.sql        |
      | QTY_CQTY_CHECK            | ${SQL_QUERIES_DIR}/QTY_CQTY_CHECK.sql            |
      | BKPG_CURR_CDE_CHECK       | ${SQL_QUERIES_DIR}/BKPG_CURR_CDE_CHECK.sql       |
      | ENT_PROC_CURR_CDE_CHECK   | ${SQL_QUERIES_DIR}/ENT_PROC_CURR_CDE_CHECK.sql   |
      | LOCAL_CURR_CDE_CHECK      | ${SQL_QUERIES_DIR}/LOCAL_CURR_CDE_CHECK.sql      |

    Examples:
      | InputFile                    | DataRow |
      | ESISODP_POS_VALID_DATA_1.out | 2       |
      | ESISODP_POS_VALID_DATA_1.out | 3       |

  Scenario Outline: TC_4: Process BNP FX Positions to DMP (4F): "<InputFile>" Other Verifications
  Verifications related to FT_T_ISSU table for the instrument created using TRAN_ID

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"

      #LONG row - 2nd row
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | TRAN_ID       | VAR_TRAN_ID       |
      | ISSUE_CCY     | VAR_ISSUE_CCY_L   |
      | MATURITY_DATE | VAR_MATURITY_DATE |

      #SHORT row - 3nd row
    And I extract below values for row 3 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | ISSUE_CCY | VAR_ISSUE_CCY_S |

    And I assign "${testdata.path}/queries" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | DENOM_CURR_CDE_CHECK | ${SQL_QUERIES_DIR}/DENOM_CURR_CDE_CHECK.sql |
      | PREF_ISS_ID_CHECK    | ${SQL_QUERIES_DIR}/PREF_ISS_ID_CHECK.sql    |
      | SRCE_CURR_CDE_CHECK  | ${SQL_QUERIES_DIR}/SRCE_CURR_CDE_CHECK.sql  |
      | TRGT_CURR_CDE_CHECK  | ${SQL_QUERIES_DIR}/TRGT_CURR_CDE_CHECK.sql  |
      | MAT_EXP_TMS_CHECK    | ${SQL_QUERIES_DIR}/MAT_EXP_TMS_CHECK.sql    |
      | PREF_ISS_NME_CHECK   | ${SQL_QUERIES_DIR}/PREF_ISS_NME_CHECK.sql   |

    Examples:
      | InputFile                    |
      | ESISODP_POS_VALID_DATA_1.out |

  Scenario: TC_5: Process BNP FX Positions to DMP (4F): Duplicate LONG record Verification
  If duplicate row of INSTR_ID, ACCT_ID and VALN_DATE combination exists in the data file, quantity of last processed row should update in the FT_T_BALH table.

    Given I assign "ESISODP_POS_VALID_DUPLICATE_ROWS_1.out" to variable "INPUT_FILENAME"
      #Duplicate LONG row

    And I extract below values for row 3 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | TRAN_ID        | VAR_TRAN_ID        |
      | VALUATION_L    | VAR_VALUATION_L    |
      | NOMINAL        | VAR_NOMINAL        |
      | LONG_SHORT_IND | VAR_LONG_SHORT_IND |

    And I execute below query and extract values of "BALH_OID" into same variables
      """
      SELECT BALH_OID
      FROM FT_T_BALH BALH
      JOIN FT_T_ISID ISID
      ON BALH.INSTR_ID=ISID.INSTR_ID
      WHERE ISID.ISS_ID = '${VAR_TRAN_ID}'
      AND ISID.ID_CTXT_TYP='FXTRANID'
      AND LDGR_ID = (CASE WHEN '${VAR_LONG_SHORT_IND}' = 'L' THEN '0020' ELSE '0040' END)
      """

    Given I assign "${testdata.path}/queries" to variable "SQL_QUERIES_DIR"

    Then I expect value of column in the below SQL query equals to "PASS"
      | LOCAL_CURR_MKT_CAMT_CHECK | ${SQL_QUERIES_DIR}/LOCAL_CURR_MKT_CAMT_CHECK.sql |
      | NOM_VAL_CAMT_CHECK        | ${SQL_QUERIES_DIR}/NOM_VAL_CAMT_CHECK.sql        |