#Ticket link : https://jira.intranet.asia/browse/TOM-4630
#Parent Ticket: https://jira.intranet.asia/browse/TOM-2026
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=R3.IN-NSC02-+Coupons+%28BRS-DMP%29+File+24#Test-logicalMapping

@gc_interface_coupon
@dmp_regression_unittest
@01_tom_4630_brs_dmp_f24_coupon_extract
Feature: BRS to DMP EOD NON-ASIA - Coupons Extract Positive Flow  - Field Mapping

  Description:
  Below Scenarios are handled as part of this feature:
  1. Loading EOD-NON-ASIA-3: Coupon Extract - F24 Feed
  2. Validating fields mapping for Income tables as per Specifications

  Scenario: Load F24 from BRS to DMP

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File24-CouponExtract/TOM-4630" to variable "testdata.path"
    And I assign "esi_ADX_EOD_NON-ASIA_COUPON_Template_PositiveFlow.xml" to variable "INPUTFILE_TEMPLATE"
    And I assign "esi_ADX_EOD_NON-ASIA_COUPON_PositiveFlow.xml" to variable "INPUT_FILENAME"

    # Dyanamic COUPON_EFF_DT generation
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "TEST_DATE"

    # Dyanamic COUPON generation
    And I generate value with date format "mmss" and assign to variable "TIMESTAMP"

    When I create input file "${INPUT_FILENAME}" using template "${INPUTFILE_TEMPLATE}" with below codes from location "${testdata.path}"
      | COUPON_EFF_DT | ${TEST_DATE}         |
      | COUPON        | 2.${TIMESTAMP}000000 |

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUPONS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #verify all the records are processed successfully
    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "1":
    """
    SELECT TASK_SUCCESS_CNT AS SUCCESS_COUNT FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
    """

      # Extracting the tag values of first record in the file:
    When I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}"  with xpath or tagName at index 0 and assign to variables:
      | COUPON        | VAR_COUPON        |
      | CUSIP         | VAR_CUSIP         |
      | COUPON_EFF_DT | VAR_COUPON_EFF_DT |

  #  FT_T_ISID : IssueIdentifier
    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID
    FROM FT_T_ISID
    WHERE ISS_ID = '${VAR_CUSIP}'
    AND ID_CTXT_TYP = 'BCUSIP'
    AND END_TMS IS NULL
    """

    Then I execute below query and extract values of "PARTICIPANT_ID" into same variables
    """
      SELECT IEVP.INC_EV_PRT_ID AS PARTICIPANT_ID
      FROM FT_T_IEVP IEVP
      INNER JOIN FT_T_IEDF IEDF
      ON IEDF.INC_EV_DEF_ID = IEVP.INC_EV_DEF_ID
      WHERE IEDF.INSTR_ID = '${INSTRUMENT_ID}'
    """

  #  FT_T_ISSU : DebtInstrumentStatistics
  Scenario: Validate Instrument ID of the CUSIP is populated in INSTR_ID Field of FT_T_ISSU Table
    Then I expect value of column "INSTR_ID" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS INSTR_ID
      FROM FT_T_ISSU
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
    """

    #  FT_T_IEDF : IncomeEventDefinition
  Scenario: Validate EV_TYP Field of FT_T_IED Table is updated as 'FLOATING'
    Then I expect value of column "INSTR_ID" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS INSTR_ID
      FROM FT_T_IEDF
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND EV_TYP = 'FLOATING'
    """

     #  FT_T_IEVP : IncomeEventParticipant
  Scenario: Validate PRT_PURP_TYP Field of FT_T_IEVP Table updated accordingly
    Then I expect value of column "PRT_PURP_TYP" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS PRT_PURP_TYP
      FROM FT_T_IEVP IEVP
      INNER JOIN FT_T_IEDF IEDF
      ON IEDF.INC_EV_DEF_ID = IEVP.INC_EV_DEF_ID
      WHERE IEDF.INSTR_ID = '${INSTRUMENT_ID}'
      AND IEVP.PRT_PURP_TYP = 'FLT'
    """

    #  FT_T_IPDF : IncomePaymentDefinition
  Scenario: Validate PRT_PURP_TYP Field of FT_T_IPDF Table updated accordingly
    Then I expect value of column "COUPON" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS COUPON
      FROM FT_T_IPDF IPDF
      INNER JOIN FT_T_IEVP IEVP
      ON IEVP.INC_EV_PRT_ID = IPDF.INC_EV_PRT_ID
      WHERE IEVP. INC_EV_PRT_ID = '${PARTICIPANT_ID}'
      AND IPDF.EV_CRTE = TRIM(TRAILING '0' FROM  '${VAR_COUPON}')
      AND IPDF.EV_RATE_BAS_TYP = 'PAR VAL'
      AND IPDF.EV_RATE_TYP = 'PERCENT'
      AND IPDF.ISS_PART_RL_TYP = 'RECEIVE'
      AND IPDF.START_TMS = TO_DATE('${VAR_COUPON_EFF_DT}','MM/DD/YYYY')
    """

