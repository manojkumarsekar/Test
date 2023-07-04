#https://collaborate.pruconnect.net/display/EISTOMR4/FA-IN-SMF-LBURCR-DMP-Security-File
#https://jira.pruconnect.net/browse/EISDEV-6128

@gc_interface_securities
@dmp_regression_unittest
@eisdev_6128 @fa_inbound @09_inbound_rcr_ROBO @dmp_fundapps_functional @fund_apps_instrument @dmp_interfaces @dmp_fundapps_regression @eisdev_6128_instrument
Feature: To verify that DMP receive the inbound instrument file data from the entity ROBO
  All the fields should be updated in dmp as per the inbound instrument RCR file.

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "ROBOEISLINSTMT20200421.CSV" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Security Id" column and assign to variables:
      | Security Id                   | ISS_ID                  |
      | ISIN                          | ISIN                    |
      | Sedol                         | SEDOL_CODE              |
      | CUSIP                         | CUSIP_CODE              |
      | Source BU Code                | SOURCE_CODE             |
      | Voting Rights Indicator       | VOTING_RIGHTS_TYP_VALUE |
      | Next Conversion Date          | NXT_CNVR_PRD_START_DTE  |
      | U/L Sec Id                    | UL_SEC_ID               |
      | Expiry Date                   | MAT_EXP_TMS             |
      | CV Terms Numerator            | CNVR_RATIO_NUMER_NUM    |
      | CV Terms Denominator          | CNVR_RATIO_DENOM_NUM    |
      | Contract Size                 | ISS_UT_CQTY             |
      | Option Type                   | CALL_PUT_TYP            |
      | Currency Of Denomination      | DENOM_CURR_CODE         |
      | Security Type/Instrument Type | SEC_TYP                 |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"

  Scenario: TC_2: Load MNG file ROBOEISLINSTMT20200421.CSV

    Given I assign "ROBOEISLINSTMT20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SECURITY |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_3: Data Verifications for 'ROBO : To verify DESC_USAGE_TYP (Description) in FT_T_ISDE table.
    Then I expect value of column "DESC_USAGE_TYP_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS DESC_USAGE_TYP_COUNT FROM FT_T_ISDE WHERE DESC_USAGE_TYP = 'PRIMARY'
       AND INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

  Scenario: TC_4: Data Verifications for 'ROBO: To verify the ISIN 

    Then I expect value of column "ISIN_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS ISIN_COUNT FROM FT_T_ISID
       WHERE ID_CTXT_TYP = 'ISIN'
       AND ISS_ID='${ISIN}'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

  Scenario: TC_5: Data Verifications for 'ROBO :To verify the SEDOL

    Then I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID
       WHERE ID_CTXT_TYP = 'SEDOL'
       AND ISS_ID='${SEDOL_CODE}'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

  Scenario: TC_6: Data Verifications for ROBO:To verify the  Source BU Code

    Then I expect value of column "DATA_SRC_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS DATA_SRC_COUNT FROM FT_T_DSRC WHERE DATA_SRC_NME='${SOURCE_CODE}' AND END_TMS IS NULL
    """

  Scenario: TC_7: Data Verifications for ROBO :To verify the  Voting Rights Indicator

    Then I expect value of column "VOTING_RIGHTS_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS VOTING_RIGHTS_COUNT FROM FT_T_EQCH WHERE VOTING_RIGHTS_TYP = (CASE WHEN '${VOTING_RIGHTS_TYP_VALUE}' = 'Y' THEN 'V' ELSE 'N' END)
       AND INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
    """

  Scenario: TC_8: Data Verifications for ROBO:To verify the  Next Conversion Date

    Then I expect value of column "PRD_START_DTE_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS PRD_START_DTE_COUNT FROM FT_T_RIST
      WHERE INSTR_ID=(
                      SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL
                      )
      AND NXT_CNVR_PRD_START_DTE IS NULL
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    """

  Scenario: TC_9: Data Verifications for ROBO:To verify the Expiry Date,Contract Size and Currency of Denomination

    Then I expect value of column "EXPIRY_DATE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXPIRY_DATE_COUNT FROM FT_T_ISSU WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND MAT_EXP_TMS IS NULL AND ISS_UT_CQTY IS NULL AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
    """

  Scenario: TC_10: Data Verifications for ROBO:To verify the CV Terms Numerator and CV Terms Denominator

    Then I expect value of column "CVTERMS_NUM_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS CVTERMS_NUM_COUNT FROM FT_T_RIST WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CNVR_RATIO_NUMER_NUM IS NULL
      AND CNVR_RATIO_DENOM_NUM IS NULL
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    """

  Scenario: TC_11: Data Verifications for ROBO:To verify the Option type

    Then I expect value of column "OPT_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS OPT_COUNT FROM FT_T_OPCH  WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'ROBOCODE' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CALL_PUT_TYP IS NULL
    """

  Scenario: TC_12: Data Verifications for ROBO:To verify the Security Type/Instrument Type

    Then I expect value of column "SECURITY_TYPE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS SECURITY_TYPE_COUNT FROM FT_T_INCL WHERE
      INDUS_CL_SET_ID = 'ROBOSCTYPE' AND CL_VALUE = '${SEC_TYP}' AND END_TMS IS NULL
    """

  Scenario: Clear the data after tests
    Then I inactivate "${ISS_ID},${SEDOL_CODE},${CUSIP_CODE},${ISIN}" instruments in GC database
    Then I inactivate "${ISS_ID},${SEDOL_CODE},${CUSIP_CODE},${ISIN}" instruments in VD database