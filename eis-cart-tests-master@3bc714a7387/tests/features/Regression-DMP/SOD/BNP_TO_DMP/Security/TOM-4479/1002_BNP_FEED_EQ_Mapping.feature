#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1002_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Equity

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Equity Security Feed
  2. Validating Equity (Convertible Bonds) specific fields mapping for FT_T_ISID and FT_T_BDCH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_EQ_LOAD.out" to variable "INPUT_FILENAME"

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

  Scenario: Load Security File for Equity

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

  Scenario: Validating if the ex-dividend column is updated based on the field value

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID        | VAR_INSTR_ID        |
      | EX_DIVIDEND_IND | VAR_EX_DIVIDEND_IND |


    Then I expect value of column "EX_DIV_IND_E" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EX_DIV_IND_E
      FROM FT_T_BDCH BDCH
      JOIN FT_T_ISID ISID
      ON BDCH.INSTR_ID = ISID.INSTR_ID
      WHERE ISID.ISS_ID = '${VAR_INSTR_ID}'
      AND ISID.END_TMS IS NULL
      AND BDCH.EX_DIV_IND = '${VAR_EX_DIVIDEND_IND}'
    """