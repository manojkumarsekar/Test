#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links:
# https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping
# https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=Domain+Validation+Data+Values#DomainValidationDataValues-BNPCOUPONFREQUENCYCODEValues
#https://jira.pruconnect.net/browse/EISDEV-7308
#EXM Rel 9 - Removing IEDF scenarios as only UPDATE is applicable for BNP

@gc_interface_securities
@dmp_regression_unittest
@1008_tom_4479_bnp_dmp_security @eisdev_7308
Feature: BNP to DMP Security feed - Field Mapping - Domain Values

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Security Feed
  2. Validating domain value mappings for FT_T_IEDF, FT_T_ISID, FT_T_ISAS and FT_T_BDCH tables as per Specifications

  Test Data - File mapping
  | DataRow | COUPON_TYPE | COUPON_FREQUENCY | FIXED_FLOATING_IND | SINKING_FUND_IND |
  | 2       | Z           | 0                | FI                 |                  |
  | 3       | F           | 12               | FL                 | N                |
  | 4       | F           | 4                |                    | N                |
  | 5       | I           | 2                |                    | N                |
  | 6       | S           | 1                | XX                 | N                |
  | 7       | V           |                  |                    |                  |
  | 8       |             |                  |                    | Y                |

  Not Covered - No matching data in the production
  | COUPON_TYPE | COUPON_FREQUENCY | FIXED_FLOATING_IND | SINKING_FUND_IND |
  |              | XX              |                    |       O          |
  |              | 28              |                    |       U          |

  Scenario: Assign Test Data Path and File name
    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISOD_SEC_DOMAIN_VAL.out" to variable "INPUT_FILENAME"

  Scenario Outline: Clear existing data for the row <RowNum> in the input file


    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID          | VAR_INSTR_ID          |
      | ISIN              | VAR_ISIN              |
      | SEDOL             | VAR_SEDOL             |
      | HIP_SECURITY_CODE | VAR_HIP_SECURITY_CODE |

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
      | 8      |

  Scenario: Process the file
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

  Scenario: 1. Validate COUPON_TYPE is 'Z' AND COUPON_FREQUENCY is '0' AND  FIXED_FLOATING_IND is 'FI'

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CouponType" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CouponType FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CPN_TYP = 'ZERO COUPON'
    """

    And I expect value of column "FixedRateCouponIndicator" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) As FixedRateCouponIndicator FROM FT_T_ISAS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND FIXED_RATE_CPN_IND = 'Y'
    """

  Scenario: 2. Validate COUPON_TYPE is 'F' AND COUPON_FREQUENCY is '12' AND SINKING_FUND_IND is 'N' FIXED_FLOATING_IND is Null

    Given I extract below values for row 3 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |


    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
        WHERE INSTR_ID = '${INSTRUMENT_ID}'
        AND CPN_TYP = 'FIXED'
        AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}'
      """

    And I expect value of column "FixedRateCouponIndicator" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) As FixedRateCouponIndicator FROM FT_T_ISAS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND FIXED_RATE_CPN_IND = 'N'
    """

  Scenario: 3. COUPON_FREQUENCY = '4', SINKING_FUND_IND = 'N',  Validate COUPON_TYPE = 'F'
    Given I extract below values for row 4 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |


    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CPN_TYP = 'FIXED'
      AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}'
    """

  Scenario: 4. Validate COUPON_TYPE is 'I' AND COUPON_FREQUENCY is '2' AND  FIXED_FLOATING_IND is Null AND SINKING_FUND_IND = 'N'

    Given I extract below values for row 5 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CPN_TYP = 'INDEXED'
      AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}'
    """

  Scenario: 5. Validate COUPON_TYPE is 'S' AND COUPON_FREQUENCY is '1' AND  FIXED_FLOATING_IND is 'XX' AND SINKING_FUND_IND = 'N'

    Given I extract below values for row 6 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CPN_TYP = 'STEP'
      AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}'
    """

    And I expect value of column "FixedRateCouponIndicator" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) As FixedRateCouponIndicator FROM FT_T_ISAS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND FIXED_RATE_CPN_IND = 'U'
    """

  Scenario: 6. Validate COUPON_TYPE is 'V' AND COUPON_FREQUENCY is '1'

    Given I extract below values for row 7 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | COUPON_FREQUENCY | VAR_COUPON_FREQUENCY |
      | COUPON_TYPE      | VAR_COUPON_TYPE      |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
     SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND CPN_TYP = 'VARIABLE'
      AND SINKABLE_IND IS NULL
    """

  Scenario: 7. Validate SINKING_FUND_IND is 'Y'

    Given I extract below values for row 8 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID         | VAR_INSTR_ID         |
      | SINKING_FUND_IND | VAR_SINKING_FUND_IND |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
      SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    And I expect value of column "CpnType_SinkableInd" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CpnType_SinkableInd FROM FT_T_BDCH
      WHERE INSTR_ID = '${INSTRUMENT_ID}'
      AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}'
    """

