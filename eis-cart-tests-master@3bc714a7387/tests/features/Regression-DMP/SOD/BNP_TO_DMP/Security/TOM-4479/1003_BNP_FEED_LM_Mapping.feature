#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1003_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Loan Mortgage

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Loan Mortgage Security Feed
  2. Validating Loan Mortgage specific fields mapping for FT_T_LMST, FT_T_BDST, FT_T_ISID and FT_T_BDCH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_LM_LOAD.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | CUSIP               | VAR_CUSIP               |
      | HIP_EXT2_ID         | VAR_HIP_EXT2_ID         |
      | BLOOMBERG_GLOBAL_ID | VAR_BLOOMBERG_GLOBAL_ID |
      | INDEX_RATIO         | VAR_INDEX_RATIO         |
      | INTEREST_MARGIN     | VAR_INTEREST_MARGIN     |
      | NEXT_COUPON_DATE    | VAR_NEXT_COUPON_DATE    |
      | COUPON_RATE         | VAR_COUPON_RATE         |
      | FACTOR              | VAR_FACTOR              |
      | FACTOR_EFF_DATE     | VAR_FACTOR_EFF_DATE     |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"

  Scenario: Load Security File for Loan Mortgage

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

  Scenario Outline: BNP Security (Loan Mortgages) Feed Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

    #IssueIdentifier table
    Examples: FT_T_ISID Table Verifications
      | Column                    | Query                                                                                                                                                                      |
      | BLOOMBERG_GLOBAL_ID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BLOOMBERG_GLOBAL_ID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'BNP_BBGLOBAL' |
      | CUSIP_CHECK               | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CUSIP_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'CUSIP'                      |

    #DebtInstrumentStatistics table
    Examples: FT_T_BDST Table Verifications
      | Column                       | Query                                                                                                                                                                                               |
      | INDX_CRTE_CHECK              | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INDX_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND INDX_CRTE = '${VAR_INDEX_RATIO}'                                |
      | CRRNT_IN_RTE_MRGN_CRTE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CRRNT_IN_RTE_MRGN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CRRNT_IN_RTE_MRGN_CRTE = '${VAR_INTEREST_MARGIN}'  |
      | NXT_CPN_DTE_CHECK            | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NXT_CPN_DTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND NXT_CPN_DTE = TO_DATE('${VAR_NEXT_COUPON_DATE}','YYYY-MM-DD') |
      | CPN_CRTE_CHECK               | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_CRTE ='${VAR_COUPON_RATE}'                                   |

    #DebtInstrumentCharacteristics table
    Examples: FT_T_BDCH Table Verifications
      | Column           | Query                                                                                                                                                 |
      | EX_DIV_IND_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS EX_DIV_IND_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND EX_DIV_IND = 'C' |
      | CPN_TYP_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_TYP_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_TYP = 'FIXED'   |

    #LoanMortgageStatistics table
    Examples: FT_T_LMST Table Verifications
      | Column                  | Query                                                                                                                                                                                                    |
      | CRRNT_FACTOR_CRTE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CRRNT_FACTOR_CRTE_CHECK FROM FT_T_LMST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CRRNT_FACTOR_CRTE = '${VAR_FACTOR}'                          |
      | FACTOR_EFF_DTE_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FACTOR_EFF_DTE_CHECK FROM FT_T_LMST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND FACTOR_EFF_DTE = TO_DATE('${VAR_FACTOR_EFF_DATE}','YYYY-MM-DD') |




