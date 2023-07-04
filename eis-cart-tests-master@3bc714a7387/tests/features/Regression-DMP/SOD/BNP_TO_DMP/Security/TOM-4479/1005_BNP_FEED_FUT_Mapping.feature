#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1005_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping -  Futures

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Futures Security Feed
  2. Validating Futures specific fields mapping for FT_T_ISID and FT_T_FECH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_FUT_LOAD.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | CUSIP               | VAR_CUSIP               |
      | HIP_EXT2_ID         | VAR_HIP_EXT2_ID         |
      | BLOOMBERG_GLOBAL_ID | VAR_BLOOMBERG_GLOBAL_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"

  Scenario: Load Security File for Futures

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    And I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

  Scenario: BNP Security Futures Feed Validations for CNTRCT_VAL_CAMT and CNTRCT_VAL_CAMT

      Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
        | INSTR_ID              | VAR_INSTR_ID              |
        | FUTURE_MULTIPLE       | VAR_FUTURE_MULTIPLE       |
        | FUTURES_DELIVERY_DATE | VAR_FUTURES_DELIVERY_DATE |

    Then I expect value of column "CNTRCT_VAL_CAMT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CNTRCT_VAL_CAMT
      FROM FT_T_FECH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CNTRCT_VAL_CAMT = '${VAR_FUTURE_MULTIPLE}'
    """

    And I expect value of column "LAST_DLV_DTE" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS LAST_DLV_DTE
      FROM FT_T_FECH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CNTRCT_VAL_CAMT = '${VAR_FUTURE_MULTIPLE}'
    """


