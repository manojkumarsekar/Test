#https://collaborate.intranet.asia/pages/viewpage.action?pageId=20611091
#https://jira.intranet.asia/browse/TOM-1359
#https://jira.pruconnect.net/browse/EISDEV-7224
#EXM Rel 7 - Changing scenarios exception text from BNPSECID to BNPLSTID

@gc_interface_positions
@dmp_regression_unittest
@dmp_pos_nfx @0102_pos_nfx_bnp_dmp @eisdev_7224
Feature: Inbound EOD Position NonFX Interface Testing (R3.IN.4F BNP to DMP) - NEGATIVE CASES

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario Outline: TC_4: Process BNP NON FX Positions to DMP (4F): Data Preparation for Negative Cases

    Given I assign "<InputFile>" to variable "INPUT_FILENAME"
    And I assign "<Template>" to variable "INPUT_TEMPLATENAME"
    And I assign "tests/test-data/dmp-interfaces/R3_IN_4F_POSNFX_BNP_TO_DMP" to variable "testdata.path"

     #These are default values for AS_OF_TMS and ADJST_TMS
    And I generate value with date format "yyyy-MMM-dd" and assign to variable "AS_OF_TMS_TEMP"
    And I generate value with date format "yyyy-MMM-dd" and assign to variable "ADJST_TMS_TEMP"

    When I modify date "${AS_OF_TMS_TEMP}" with "-1d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "AS_OF_TMS"
    When I modify date "${ADJST_TMS_TEMP}" with "-1d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "ADJST_TMS"
    When I modify date "${AS_OF_TMS_TEMP}" with "-2d" from source format "yyyy-MMM-dd" to destination format "yyyy-MMM-dd" and assign to "PRICE_DATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Examples:
      | InputFile                            | Template                                      |
      | ESISODP_SDP_WITH_NO_INSTRID.out      | ESISODP_SDP_WITH_NO_INSTRID_Template.out      |
      | ESISODP_SDP_WITH_INVALID_INSTRID.out | ESISODP_SDP_WITH_INVALID_INSTRID_Template.out |
      | ESISODP_SDP_WITH_NO_ASSETTYPE.out    | ESISODP_SDP_WITH_NO_ASSETTYPE_Template.out    |
      | ESISODP_SDP_WITH_INVALID_ACCTID.out  | ESISODP_SDP_WITH_INVALID_ACCTID_Template.out  |
      | ESISODP_SDP_WITH_ASSETTYPE_FX.out    | ESISODP_SDP_WITH_ASSETTYPE_FX_Template.out    |

  Scenario: TC_5: Process BNP NON FX Positions to DMP (4F): Data Loading for Negative Cases

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED | EIS_BF_BNP_FIXEDHEADER             |
      | FILE_PATTERN  | ESISODP_SDP_*.out                  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM |

  Scenario: TC_6: Process BNP NON FX Positions to DMP (4F): No INSTR ID Verification

    Then I expect value of column "NO_INSTRID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_INSTRID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_NO_INSTRID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record.'
    AND NTEL.NOTFCN_ID='60001'
    AND NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields, SECURITY is not present in the input record%'
    """

    Then I expect value of column "NO_INSTRID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_INSTRID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_NO_INSTRID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='Table Initial Occurence: 3 No lookup indentifier available'
    AND NTEL.NOTFCN_ID='153'
    AND NTEL.CHAR_VAL_TXT LIKE '%Table Initial Occurence: 3 Segment Failed as a fatal error occurred while processing message.Additional information:No lookup indentifier available.%'
    """


  # Notification 23 does not throw exception for NO_INSTR_ID_CHECK  as it is failed in first lookup segment for FT_T_ACID

#    Then I expect value of column "NO_INSTRID_CHECK" in the below SQL query equals to "PASS":
#      """
#     SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_INSTRID_CHECK FROM FT_T_NTEL NTEL
#    JOIN FT_T_TRID TRID
 #   ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
#WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
 #       TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
  #      JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_NO_INSTRID%.out' AND
   #     TASK_CMPLTD_CNT > 0)
 #   AND NTEL.PARM_VAL_TXT='BNPSECID  BNP IssueIdentifier'
  #  AND NTEL.NOTFCN_ID='23'
   # AND NTEL.CHAR_VAL_TXT LIKE '%The Issue for ''BNPSECID - '' provided by BNP is not present in the IssueIdentifier%'
   # """

  Scenario: TC_7: Process BNP NON FX Positions to DMP (4F): Invalid INSTR ID Verification

    Then I expect value of column "INVALID_INSTRID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS INVALID_INSTRID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_INVALID_INSTRID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='BNPLSTID MD_00007 BNP IssueIdentifier'
    AND NTEL.NOTFCN_ID='23'
    AND NTEL.CHAR_VAL_TXT LIKE '%The Issue for ''BNPLSTID - MD_00007'' provided by BNP is not present in the IssueIdentifier.%'
    """

    Then I expect value of column "INVALID_INSTRID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS INVALID_INSTRID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_INVALID_INSTRID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='Table BalanceHistory Occurence: 0 Could not resolve nested segment.'
    AND NTEL.NOTFCN_ID='153'
    AND NTEL.CHAR_VAL_TXT LIKE '%Table BalanceHistory Occurence: 0 Segment Failed as a fatal error occurred while processing message.Additional information:Could not resolve nested segment.%'
    """

  Scenario: TC_8: Process BNP NON FX Positions to DMP (4F): NO ASSET TYPE Verification

    Then I expect value of column "NO_ASSET_TYPE_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_ASSET_TYPE_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_NO_ASSETTYPE%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required fields ASSET_TYPE is not present in the input record.'
    AND NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_ID='60001'
    AND NTEL.CHAR_VAL_TXT LIKE '%Missing Data Exception:- User defined Error thrown! . Cannot process file as required fields ASSET_TYPE is not present in the input record%'
    """

  # Notification 16 does not use for exception now.

 # Then I expect value of column "NO_ASSET_TYPE_CHECK" in the below SQL query equals to "PASS":
 #   """
 #   SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS NO_ASSET_TYPE_CHECK FROM FT_T_NTEL NTEL
  #  JOIN FT_T_TRID TRID
   # ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    #WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
     #   TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
      #  JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_NO_ASSETTYPE%.out' AND
       # TASK_CMPLTD_CNT > 0)
    #AND NTEL.PARM_VAL_TXT='No message generated due to message conditions that resulted in an empty value'
   # AND NTEL.SOURCE_ID='TRANSLATION'
   # AND NTEL.NOTFCN_ID='16'
   # AND NTEL.CHAR_VAL_TXT LIKE '%A warning occurred during translation. Additional information: No message generated due to message conditions that resulted in an empty value.%'
   # """

  Scenario: TC_9: Process BNP NON FX Positions to DMP (4F): INVALID ACCT ID Verification

    Then I expect value of column "INVALID_ACCT_ID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS INVALID_ACCT_ID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_INVALID_ACCTID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='BNPPRTID ABCDEF BNP AccountAlternateIdentifier'
    AND NTEL.NOTFCN_ID='26'
    AND NTEL.CHAR_VAL_TXT LIKE '%The Account Alternate Identifier ''BNPPRTID - ABCDEF'' received from BNP  could not be retrieved from the AccountAlternateIdentifier%'
    """

    Then I expect value of column "INVALID_ACCT_ID_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=1 THEN 'PASS' ELSE 'FAIL' END AS INVALID_ACCT_ID_CHECK FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID
    WHERE TRID.JOB_ID=(SELECT JOB_ID FROM FT_T_JBLG WHERE
        TO_TIMESTAMP(TO_CHAR(JOB_START_TMS,'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') >= TO_TIMESTAMP(TO_CHAR((SELECT WORKFLOW_START_TMS FROM FT_WF_WFRI WHERE INSTANCE_ID = '${flowResultId}'),'DD-MON-YYYYHH24:MI:SS'),'DD-MON-YYYYHH24:MI:SS') AND
        JOB_INPUT_TXT LIKE '%ESISODP_SDP_WITH_INVALID_ACCTID%.out' AND
        TASK_CMPLTD_CNT > 0)
    AND NTEL.PARM_VAL_TXT='Table BalanceHistory Occurence: 0 Could not resolve nested segment.'
    AND NTEL.NOTFCN_ID='153'
    AND NTEL.CHAR_VAL_TXT LIKE '%Table BalanceHistory Occurence: 0 Segment Failed as a fatal error occurred while processing message.Additional information:Could not resolve nested segment%'
    """

  Scenario: TC_10: Process BNP NON FX Positions to DMP (4F): ASSET TYPE AS 'FX' Verification

     #FX Template has all values set to '0' so with current date there should be zero records with all values as 0 then concluding FX record is ignored
    Then I expect value of column "ASSET_TYPE_FX_CHECK" in the below SQL query equals to "PASS":
    """
    SELECT CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END AS ASSET_TYPE_FX_CHECK FROM FT_T_BALH
    WHERE TO_CHAR(AS_OF_TMS,'YYYY-MON-DD')= '${AS_OF_TMS}'
    AND TO_CHAR(ADJST_TMS,'YYYY-MON-DD')= '${ADJST_TMS}'
    AND QTY_CQTY=0
    AND LOCAL_CURR_MKT_CAMT=0
    AND BKPG_CURR_MKT_CAMT=0
    AND NOM_VAL_CAMT=0
    AND BKPG_CURR_INC_ACCR_CAMT=0
    AND LOCAL_CURR_INC_ACCR_CAMT=0
    """

