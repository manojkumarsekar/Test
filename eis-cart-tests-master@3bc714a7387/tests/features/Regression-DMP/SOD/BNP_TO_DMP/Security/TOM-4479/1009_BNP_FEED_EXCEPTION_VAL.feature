#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping
#https://jira.pruconnect.net/browse/EISDEV-7224
#EXM Rel 7 - Removing scenarios for exception validations with non mandatory INSTR_ID (BNP MD_ID)

#01-- INSTR_ID Missing
#02-- ISSUE_CCY Missing
#03-- INSTR_TYPE Missing
#04-- Factor is present and factor effective date is missing
#010-- HIP_EXT2_ID Missing
#011-- HIP_EXT2_ID exceeds 9 char
#012-- PRIMARY_EXCHANGE is X or XX
#013-- COUNTRY_OF_RISK is missing
#014-- COUNTRY_OF_ISSUE is missing
#015-- Invalid domain value

#Exceptions on options -- Not covered since exception will only be thrown if the option securities INSTR_TYPE has 2nd char = 'O' and 4th char = 'C'. No such records are currently available.--
#06-- EXPIRY_DATE is missing
#07-- HIP_EXT2_ID is missing
#08-- FX_OPTION_CONTRA_CCY is missing
#09-- HIP_SECURITY_CODE is missing
#010-- PUT_CALL_IND is missing
#05-- Factor effective date is present and factor  is missing(record got processed)

@gc_interface_securities
@dmp_regression_unittest
@1009_tom_4479_bnp_dmp_security @eisdev_7224
Feature: BNP to DMP Security feed - Field Mapping - Exception Validation

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Security Feed
  2. Validating mandatory field missing, domain value and char limit exceptions for FT_T_NTEL table as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_EXCP_VAL.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID          | VAR_INSTR_ID          |
      | ISIN              | VAR_ISIN              |
      | SEDOL             | VAR_SEDOL             |
      | CUSIP             | VAR_CUSIP             |
      | HIP_EXT2_ID       | VAR_HIP_EXT2_ID       |
      | HIP_SECURITY_CODE | VAR_HIP_SECURITY_CODE |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_CUSIP}','${VAR_SEDOL}','${VAR_HIP_EXT2_ID}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_CUSIP}','${VAR_SEDOL}','${VAR_HIP_EXT2_ID}','${VAR_HIP_SECURITY_CODE}'"

  Scenario: Load Security File to trigger Exceptions


    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: 01_Verify missing INSTR_ID exception

    Then I expect value of column "INSTR_ID_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INSTR_ID_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Cannot process record as required field%INSTR_ID%')
    """

  Scenario: 02_Verify missing ISSUE_CCY exception

    Then I expect value of column "ISSUE_CCY_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ISSUE_CCY_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Cannot process record as required field%ISSUE_CCY%')
    """

  Scenario: 03_Verify missing INSTR_TYPE exception

    Then I expect value of column "INSTR_TYPE_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INSTR_TYPE_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Cannot process record as required field%INSTR_TYPE%')
    """

  Scenario: 04_Verify missing Factor exception for Loan Mortgage security

    Then I expect value of column "FACTOR_EFF_DATE_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FACTOR_EFF_DATE_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Cannot process the record as required field%FACTOR EFF DATE%')
    """

  Scenario: 11_Verify  HIP_EXT2_ID char limit exception

    Then I expect value of column "HIP_EXT2_ID_CHAR_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS HIP_EXT2_ID_CHAR_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60003
    AND NTEL.MSG_SEVERITY_CDE = '40'
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . Length of HIP_EXT2_ID is not equal to  9%')
    """

  Scenario: 12_Verify undefined PRIMARY_EXCHANGE exception

    Then I expect value of column "PRIMARY_EXCHANGE_XX_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS PRIMARY_EXCHANGE_XX_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.MSG_SEVERITY_CDE = '30'
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . PRIMARY EXCHAGE  is X or XX in the input record , please check%')
    """

  Scenario: 13_Verify undefined COUNTRY_OF_RISK exception

    Then I expect value of column "COUNTRY_OF_RISK_XX_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS COUNTRY_OF_RISK_XX_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.MSG_SEVERITY_CDE = '30'
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . COUNTRY OF RISK is X or XX in the input record , please check%')
    """

  Scenario: 14_Verify undefined COUNTRY_OF_ISSUE exception

    Then I expect value of column "COUNTRY_OF_ISSUE_XX_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS COUNTRY_OF_ISSUE_XX_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    AND TRID.JOB_ID = '${JOB_ID}'
    WHERE NTEL.SOURCE_ID='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.NOTFCN_ID=60001
    AND NTEL.MSG_SEVERITY_CDE = '30'
    AND NTEL.PARM_VAL_TXT LIKE ('User defined Error thrown! . COUNTRY OF ISSUE is X or XX in the input record , please check%')
    """

  Scenario: 15_Domain Value Exception Validation

    Then I expect value of column "INSTR_ID_EXCEPTION" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INSTR_ID_EXCEPTION FROM FT_T_NTEL NTEL
    JOIN FT_T_TRID TRID
    ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
    WHERE TRID.JOB_ID IN ('${JOB_ID}')
    AND NTEL.SOURCE_ID ='TRANSLATION'
    AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
    AND NTEL.CHAR_VAL_TXT LIKE ('An error occurred during translation%')
    AND NTEL.MSG_SEVERITY_CDE = '50'
    AND NTEL.NOTFCN_ID = '15'
    """
