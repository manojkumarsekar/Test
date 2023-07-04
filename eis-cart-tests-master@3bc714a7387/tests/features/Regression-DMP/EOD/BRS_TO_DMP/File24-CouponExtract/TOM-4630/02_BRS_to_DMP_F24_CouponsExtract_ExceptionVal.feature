#Ticket link : https://jira.intranet.asia/browse/TOM-4630
#Parent Ticket: https://jira.intranet.asia/browse/TOM-2026
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=R3.IN-NSC02-+Coupons+%28BRS-DMP%29+File+24#Test-logicalMapping

@gc_interface_coupon
@dmp_regression_unittest
@02_tom_4630_brs_dmp_f24_coupon_extract
Feature: BRS to DMP EOD NON-ASIA - Coupons Extract Positive Flow  - Exception Validation

  Validate that system throw exception and should not process the records when:
  1.) CUSIP is NULL
  2.) COUPON_EFF_DT is NULL
  3.) COUPON is NULL
  4.) Invalid CUSIP

  Scenario: Load F24 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File24-CouponExtract/TOM-4630" to variable "testdata.path"
    And I assign "esi_ADX_EOD_NON-ASIA_COUPON_Template_ExceptionVal.xml" to variable "INPUTFILE_TEMPLATE"
    And I assign "esi_ADX_EOD_NON-ASIA_COUPON_ExceptionVal.xml" to variable "INPUT_FILENAME"

    # Dyanamic COUPON_EFF_DT generation
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "TEST_DATE"

    # Dyanamic COUPON generation
    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | COUPON_EFF_DT1 | ${TEST_DATE}         |
      | COUPON1        | 2.${TIMESTAMP}000000 |
      | COUPON_EFF_DT2 | ${TEST_DATE}         |
      | COUPON2        | 3.${TIMESTAMP}000000 |
      | COUPON_EFF_DT3 | ${TEST_DATE}         |
      | COUPON3        | 4.${TIMESTAMP}000000 |
      | COUPON_EFF_DT4 | ${TEST_DATE}         |
      | COUPON4        | 1.${TIMESTAMP}000000 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUPONS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify the erroneous records considered in TASK_SUCCESS_CNT (Except when CUSIP is Invalid)
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "3":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

  Scenario:  Validate that NO record added to FT_T_IPDF table when CUSIP is NULL is NULL in Record 1

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUPON" at index 0 to variable "VAR_COUPON1"
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUPON_EFF_DT" at index 0 to variable "VAR_COUPON_EFF_DT1"

        #  FT_T_IPDF : IncomePaymentDefinition
    Then I expect value of column "COUPON" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS COUPON
      FROM FT_T_IPDF IPDF
      WHERE IPDF.EV_CRTE = TRIM(TRAILING '0' FROM  '${VAR_COUPON1}')
      AND IPDF.EV_RATE_BAS_TYP = 'PAR VAL'
      AND IPDF.EV_RATE_TYP = 'PERCENT'
      AND IPDF.ISS_PART_RL_TYP = 'RECEIVE'
      AND IPDF.START_TMS = TO_DATE('${VAR_COUPON_EFF_DT1}','MM/DD/YYYY')
    """

  Scenario:  Validate that system throw exception when COUPON_EFF_DT is NULL in Record 2

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUPON" at index 1 to variable "VAR_COUPON2"
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//CUSIP" at index 1 to variable "VAR_CUSIP2"

    Then I expect value of column "EXCEPTION_COUPON_EFF_DT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXCEPTION_COUPON_EFF_DT FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      WHERE NTEL.SOURCE_ID LIKE 'TRANSLATION'
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.NOTFCN_ID = 60001
      AND NTEL.MSG_SEVERITY_CDE = 30
      AND NTEL.PART_ID = 'TRANS'
      AND NTEL.MAIN_ENTITY_ID = '${VAR_CUSIP2}'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP'
      AND NTEL.PARM_VAL_TXT = 'User defined Error thrown! . COUPON EFFECTIVE DATE is not present in the input record.'
      AND NTEL.CHAR_VAL_TXT = 'Missing Data Exception:- User defined Error thrown! . COUPON EFFECTIVE DATE is not present in the input record.'
    """

  Scenario: Validate that NO record added to FT_T_IPDF table when COUPON is NULL in Record 3

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//CUSIP" at index 2 to variable "VAR_CUSIP3"

    #  FT_T_ISID : IssueIdentifier
    Then I execute below query and extract values of "INSTRUMENT_ID3" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID3
    FROM FT_T_ISID
    WHERE ISS_ID = '${VAR_CUSIP3}'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND END_TMS IS NULL
    """

    Then I execute below query and extract values of "PARTICIPANT_ID3" into same variables
    """
      SELECT IEVP.INC_EV_PRT_ID AS PARTICIPANT_ID3
      FROM FT_T_IEVP IEVP
      INNER JOIN FT_T_IEDF IEDF
      ON IEDF.INC_EV_DEF_ID = IEVP.INC_EV_DEF_ID
      WHERE IEDF.INSTR_ID = '${INSTRUMENT_ID3}'
    """

    Then I expect value of column "COUPON" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS COUPON
      FROM FT_T_IPDF IPDF
      INNER JOIN FT_T_IEVP IEVP
      ON IEVP.INC_EV_PRT_ID = IPDF.INC_EV_PRT_ID
      WHERE IEVP. INC_EV_PRT_ID = '${PARTICIPANT_ID3}'
      AND IPDF.EV_CRTE = TRIM(TRAILING '0' FROM  '${COUPON3}')
      AND IPDF.EV_RATE_BAS_TYP = 'PAR VAL'
      AND IPDF.EV_RATE_TYP = 'PERCENT'
      AND IPDF.ISS_PART_RL_TYP = 'RECEIVE'
      AND IPDF.START_TMS = TO_DATE('${COUPON_EFF_DT3}','MM/DD/YYYY')
    """

  Scenario: Validate that system throw exception when CUSIP is invalid in Record 4

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//CUSIP" at index 3 to variable "VAR_CUSIP4"

    #  FT_T_ISID : IssueIdentifier
    Then I expect value of column "INSTRUMENT_ID4" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS INSTRUMENT_ID4
    FROM FT_T_ISID
    WHERE ISS_ID = '${VAR_CUSIP4}'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND END_TMS IS NULL
    """

    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUPON" at index 3 to variable "VAR_COUPON4"
    When I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with xpath "//COUPON_EFF_DT" at index 3 to variable "VAR_COUPON_EFF_DT4"

        #  FT_T_IPDF : IncomePaymentDefinition
    Then I expect value of column "COUPON4" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS COUPON4
      FROM FT_T_IPDF IPDF
      WHERE IPDF.EV_CRTE = TRIM(TRAILING '0' FROM  '${VAR_COUPON4}')
      AND IPDF.EV_RATE_BAS_TYP = 'PAR VAL'
      AND IPDF.EV_RATE_TYP = 'PERCENT'
      AND IPDF.ISS_PART_RL_TYP = 'RECEIVE'
      AND IPDF.START_TMS = TO_DATE('${VAR_COUPON_EFF_DT4}','MM/DD/YYYY')
    """

    Then I expect value of column "EXCEPTION_CUSIP" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXCEPTION_CUSIP FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      WHERE NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.NOTFCN_ID = 153
      AND NTEL.MSG_SEVERITY_CDE = 50
      AND NTEL.PART_ID = 'STRDATA '
      AND NTEL.MAIN_ENTITY_ID = '${VAR_CUSIP4}'
      AND NTEL.MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP'
      AND NTEL.PARM_VAL_TXT = 'Table Initial Occurence: 4 No lookup indentifier available'
      AND NTEL.CHAR_VAL_TXT = 'Table Initial Occurence: 4 Segment Failed as a fatal error occurred while processing message.Additional information:No lookup indentifier available.'
    """