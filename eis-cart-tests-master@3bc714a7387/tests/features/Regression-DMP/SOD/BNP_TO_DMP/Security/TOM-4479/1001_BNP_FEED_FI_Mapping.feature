#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1001_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Fixed Income

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Fixed Income Security Feed
  2. Validating Fixed Income specific fields mapping for FT_T_BDST and FT_T_BDCH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_FI_LOAD.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID          | VAR_INSTR_ID          |
      | ISIN              | VAR_ISIN              |
      | SEDOL             | VAR_SEDOL             |
      | HIP_SECURITY_CODE | VAR_HIP_SECURITY_CODE |
      | INSTR_TYPE        | VAR_INSTR_TYPE        |
      | SINKING_FUND_IND  | VAR_SINKING_FUND_IND  |
      | COUPON_TYPE       | VAR_COUPON_TYPE       |
      | COUPON_RATE       | VAR_COUPON_RATE       |
      | INDEX_RATIO       | VAR_INDEX_RATIO       |
      | INTEREST_MARGIN   | VAR_INTEREST_MARGIN   |
      | NEXT_COUPON_DATE  | VAR_NEXT_COUPON_DATE  |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"

  Scenario: Load Security File for Fixed Income

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

  Scenario Outline: BNP Security (Fixed Income) Feed Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

	#DebtInstrumentStatistics table
    Examples: FT_T_BDST Table Verifications
      | Column                       | Query                                                                                                                                                                                               |
      | CPN_CRTE_CHECK               | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_CRTE = '${VAR_COUPON_RATE}'                                  |
      | INDX_CRTE_CHECK              | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INDX_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND INDX_CRTE = '${VAR_INDEX_RATIO}'                                |
      | CRRNT_IN_RTE_MRGN_CRTE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CRRNT_IN_RTE_MRGN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CRRNT_IN_RTE_MRGN_CRTE = '${VAR_INTEREST_MARGIN}'  |
      | NXT_CPN_DTE_CHECK            | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NXT_CPN_DTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND NXT_CPN_DTE = TO_DATE('${VAR_NEXT_COUPON_DATE}','YYYY-MM-DD') |

	#DebtInstrumentCharacteristics table
    Examples: FT_T_BDCH Table Verifications
      | Column             | Query                                                                                                                                                                           |
      | EX_DIV_IND_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS EX_DIV_IND_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND EX_DIV_IND = 'C'                           |
      | SINKABLE_IND_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SINKABLE_IND_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}' |
      | CPN_TYP_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_TYP_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_TYP = 'FIXED'                             |