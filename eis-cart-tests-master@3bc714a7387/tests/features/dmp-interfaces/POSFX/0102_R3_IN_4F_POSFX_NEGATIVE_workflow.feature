#https://collaborate.intranet.asia/pages/viewpage.action?pageId=14790745
#https://jira.intranet.asia/browse/TOM-1241
#TOM-4673: As part of TOM-4534, we have disabled the segments for ACST and hence the related exceptions will not be thrown.
# Removing the excption check from feature file

@gc_interface_positions
@dmp_regression_unittest
@dmp_pos_fx @0102_pos_fx_bnp_dmp @tom_4673
Feature: Inbound EOD Position FX Interface Testing (R3.IN.4F BNP to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario Outline: TC_6: Process BNP FX Positions to DMP (4F): "<InputFile>" Data Preparation

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"
    And I assign "<Template>" to variable "INPUT_TEMPLATENAME"

    And I assign "tests/test-data/dmp-interfaces/R3_IN_4F_POSFX_BNP_TO_DMP" to variable "testdata.path"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | TRAN_ID | DateTimeFormat:dHmsS |

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Examples:
      | InputFile                                 | Template                                         |
      | ESISODP_POS_WITH_INVALID_ASSET_TYPE_1.out | ESISODP_POS_WITH_INVALID_ASSET_TYPE_Template.out |
      | ESISODP_POS_WITH_INVALID_INQ_BS_1.out     | ESISODP_POS_WITH_INVALID_INQ_BS_Template.out     |
      | ESISODP_POS_WITH_NO_LSI_1.out             | ESISODP_POS_WITH_NO_LSI_Template.out             |
      | ESISODP_POS_WITH_NO_ACCT_ID_1.out         | ESISODP_POS_WITH_NO_ACCT_ID_Template.out         |
      | ESISODP_POS_WITH_NO_INSTR_ID_1.out        | ESISODP_POS_WITH_NO_INSTR_ID_Template.out        |
      | ESISODP_POS_WITH_NO_TRAN_ID_1.out         | ESISODP_POS_WITH_NO_TRAN_ID_Template.out         |
      | ESISODP_POS_WITH_NO_VALN_DATE_1.out       | ESISODP_POS_WITH_NO_VALN_DATE_Template.out       |

  Scenario: TC_7: Process BNP FX Positions to DMP (4F): Data Loading

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER          |
      | FILE_PATTERN  | ESISODP_POS_*.out               |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_LATAM |

  Scenario Outline: TC_8: Process BNP FX Positions to DMP (4F): FT_T_BALH VERIFICATIONS FOR "<InputFile>"

    Given I extract below values for row 2 from PSV file "<InputFile>" in local folder "${testdata.path}/testdata" and assign to variables:
      | TRAN_ID | VAR_TRAN_ID |

    Then I expect value of column "NO_DATA_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END AS NO_DATA_CHECK
      FROM FT_T_BALH BALH
        JOIN FT_T_ISID ISID
      ON BALH.INSTR_ID=ISID.INSTR_ID
      WHERE ISID.ISS_ID = '${VAR_TRAN_ID}'
      AND ISID.ID_CTXT_TYP='FXTRANID'
      """

    Examples:
      | InputFile                                 |
      | ESISODP_POS_WITH_INVALID_ASSET_TYPE_1.out |
      | ESISODP_POS_WITH_INVALID_INQ_BS_1.out     |
      | ESISODP_POS_WITH_NO_LSI_1.out             |
      | ESISODP_POS_WITH_NO_ACCT_ID_1.out         |
      | ESISODP_POS_WITH_NO_INSTR_ID_1.out        |
      | ESISODP_POS_WITH_NO_VALN_DATE_1.out       |

  Scenario Outline: TC_9: Process BNP FX Positions to DMP (4F): FT_T_BALH VERIFICATIONS FOR "ESISODP_POS_WITH_NO_TRAN_ID_1.out" Row <DataRow>

    Given I extract below values for row <DataRow> from PSV file "ESISODP_POS_WITH_NO_TRAN_ID_1.out" in local folder "${testdata.path}/testdata" and assign to variables:
      | VALUATION_L | VAR_VALUATION_L |
      | NOMINAL     | VAR_NOMINAL     |
      | VALN_DATE   | VAR_VALN_DATE   |

    Then I expect value of column "NO_DATA_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END AS NO_DATA_CHECK
      FROM FT_T_BALH BALH
      WHERE LOCAL_CURR_MKT_CAMT=${VAR_VALUATION_L}
      AND NOM_VAL_CAMT=${VAR_NOMINAL}
      AND TO_CHAR(AS_OF_TMS,'YYYY-MON-DD')= '${VALN_DATE}'
      """
    Examples:
      | DataRow |
      | 2       |
      | 3       |

  Scenario: TC_10: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - NO_INSTR_ID_CHECK

    Then I expect value of column "NO_INSTR_ID_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_INSTR_ID_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_NO_INSTR_ID%.out' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record.'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record%'
      """

  Scenario: TC_11: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - NO_LONG_SHORT_IND_CHECK

    Then I expect value of column "NO_LONG_SHORT_IND_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS NO_LONG_SHORT_IND_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_NO_LSI%.out' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, LONG_SHORT_IND is not present in the input record%'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, LONG_SHORT_IND is not present in the input record%'
      """

  Scenario: TC_12: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - NO_ACCT_ID_CHECK

    Then I expect value of column "NO_ACCT_ID_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS NO_ACCT_ID_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_NO_ACCT_ID%.out' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, PORTFOLIO is not present in the input record.%'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, PORTFOLIO is not present in the input record%'
      """

  Scenario: TC_13: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - NO_TRAN_ID_CHECK

    Then I expect value of column "NO_TRAN_ID_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS NO_TRAN_ID_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_NO_TRAN_ID%.out' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields TRANSACTION ID is not present in the input record.%'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields TRANSACTION ID is not present in the input record%'
      """

  Scenario: TC_14: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - NO_VALN_DATE_CHECK

    Then I expect value of column "NO_VALN_DATE_CHECK" in the below SQL query equals to "PASS":
      """
      SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS NO_VALN_DATE_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
      WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
          TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
          JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_NO_VALN_DATE%.out' AND
          TASK_CMPLTD_CNT > 0)
      AND NTEL.PARM_VAL_TXT LIKE '%User defined Error thrown! . Cannot process file as required fields, VALN_DATE is not present in the input record.%'
      AND NTEL.NOTFCN_ID='60001'
      AND NTEL.SOURCE_ID='TRANSLATION'
      AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, VALN_DATE is not present in the input record%'
      """

  # Notification 16 does not use for exception now.


 # Scenario: TC_15: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - INVALID_ASSET_TYPE_CHECK

 #   Then I expect value of column "INVALID_ASSET_TYPE_CHECK" in the below SQL query equals to "PASS":
  #  """
   # SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS INVALID_ASSET_TYPE_CHECK FROM FT_T_NTEL NTEL
    #JOIN FT_T_TRID TRID
  #  ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
   # WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
    #    TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
     #   JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_INVALID_ASSET_TYPE%.out' AND
      #  TASK_CMPLTD_CNT > 0)
  #  AND NTEL.PARM_VAL_TXT LIKE '%Warning on parsing input message: Message contains less fields than MSF layout has defined%'
   # AND NTEL.NOTFCN_ID='16'
    #AND NTEL.SOURCE_ID='TRANSLATION'
    #AND NTEL.CHAR_VAL_TXT LIKE '%Message contains less fields than MSF layout has defined%'
    #"""

 # Scenario: TC_16: Process BNP FX Positions to DMP (4F): FT_T_NTEL VERIFICATIONS FOR INVALID CASES - INVALID_INQBS_CHECK

  #  Then I expect value of column "INVALID_INQBS_CHECK" in the below SQL query equals to "PASS":
   # """
    #SELECT CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END AS INVALID_INQBS_CHECK FROM FT_T_NTEL NTEL
 #   JOIN FT_T_TRID TRID
 #   ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
  #  WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
   #     TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
    #    JOB_INPUT_TXT LIKE '%ESISODP_POS_WITH_INVALID_INQ_BS%.out' AND
     #   TASK_CMPLTD_CNT > 0)
 #   AND NTEL.PARM_VAL_TXT LIKE '%No message generated due to message conditions that resulted in an empty value%'
  #  AND NTEL.NOTFCN_ID='16'
   # AND NTEL.SOURCE_ID='TRANSLATION'
    #"""
