#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping
#https://jira.pruconnect.net/browse/EISDEV-7308
#EXM Rel 9 - Removing IEDF scenarios as only UPDATE is applicable for BNP

@gc_interface_securities
@dmp_regression_unittest
@1007_tom_4479_bnp_dmp_security @eisdev_7308
Feature: BNP to DMP Security feed - Field Mapping - Swaps

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Swaps Security Feed
  2. Validating Swaps specific fields mapping for FT_T_RIDF, FT_T_IEDF, FT_T_ISID, FT_T_ISST and FT_T_SWCH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_SWP_LOAD.out" to variable "INPUT_FILENAME"

  Scenario Outline: Clear existing data for the row <RowNum> in the input file

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | CUSIP               | VAR_CUSIP               |
      | HIP_EXT2_ID         | VAR_HIP_EXT2_ID         |
      | BLOOMBERG_GLOBAL_ID | VAR_BLOOMBERG_GLOBAL_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"

    Examples:
      | RowNum |
      | 2      |
      | 3      |
      | 4      |
      | 5      |
      | 6      |
      | 7      |

  Scenario: Load Security File for Swaps

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

  Scenario Outline: <RowNum1>. SWAP Classification Type is <CL_Value> AND SWAP Leg Indicator is <Value_SWAP_DIRECT_TYP>

    Given I extract below values for row <RowNum1> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID      | VAR_INSTR_ID      |
      | LINK_INSTR_ID | VAR_LINK_INSTR_ID |
      | SWAP_LEG_IND  | VAR_SWAP_LEG_IND  |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

#  FT_T_SWCH: Swap Characteristics
    And I expect value of column "Expected_FT_T_SWCH" in the below SQL query equals to "1":
     """
          SELECT COUNT(*) AS Expected_FT_T_SWCH from FT_T_SWCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND SWAP_DIRECT_TYP = '<Value_SWAP_DIRECT_TYP>'
    """

#  FT_T_RIDF: Related Issue Definition
    And I expect value of column "Expected_FT_T_RIDF" in the below SQL query equals to "1":
     """
      SELECT COUNT(*) AS Expected_FT_T_RIDF
      FROM FT_T_RIDF
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND DATA_STAT_TYP = 'ACTIVE'
      AND REL_TYP = 'SWAP'
      AND REL_DESC = '${VAR_LINK_INSTR_ID}--Identifying the Security for Swaps'
    """

    Examples:
      | RowNum1 | Value_SWAP_DIRECT_TYP | CL_Value |
      | 2       | RECEIVE               | CAP      |
      | 3       | PAY                   | CAP      |
      | 4       | RECEIVE               | TRSWAP   |
      | 5       | PAY                   | TRSWAP   |
      | 6       | RECEIVE               | CSWAP    |
      | 7       | PAY                   | CSWAP    |

  Scenario: 8. Validate CLEARED_OTC_FLAG Field Mapping

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | CLEARED_OTC_FLAG | VAR_CLEARED_OTC_FLAG |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CLEARED_OTC_FLAG" in the below SQL query equals to "1":
   """
      SELECT COUNT(*) AS CLEARED_OTC_FLAG
      FROM FT_T_ISST
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND STAT_CHAR_VAL_TXT = '${VAR_CLEARED_OTC_FLAG}'
    """

  Scenario: 9.  Validate HIP_INDEX_CODE Field Mapping

    Given I extract below values for row 3 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID       | VAR_INSTR_ID       |
      | HIP_INDEX_CODE | VAR_HIP_INDEX_CODE |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """