#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
#Dev Ticket     : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket : https://jira.intranet.asia/browse/TOM-4265

@gc_interface_securities
@dmp_regression_unittest
@dmp_fundapps_regression
@tom_4265 @10_inbound_rcr_legacy @dmp_fundapps_functional @fund_apps_instrument @fa_inbound
Feature: To verify that DMP receive the inbound instrument file data from the entity TW\BONY\HIPORT
  All the fields should be updated in dmp as per the inbound instrument RCR file

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "LEGAEEISLINSTMT_20190321_1_20190325.csv" to variable "INPUT_FILENAME"
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
      | Currency of Denomination      | DENOM_CURR_CODE         |
      | Security Type/Instrument Type | SEC_TYP                 |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"

  Scenario: TC_2: Load MNG file MANGEISLINSTMT20180219.csv
    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_LEGACY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """

  Scenario: TC_3: Data Verifications for TW\BONY\HIPORT: To verify  the inbound instrument file load in to DMP  from the entity TW\BONY\HIPORT
    Then I expect value of column "JOB_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS JOB_ID FROM FT_T_JBLG WHERE JOB_STAT_TYP='CLOSED'
    AND JOB_MSG_TYP='EIS_MT_LEGACY_DMP_SECURITY' AND JOB_ID = '${JOB_ID}' AND JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
    """

  Scenario: TC_4: Data Verifications for TW\BONY\HIPORT : To verify the Security_id from file in to DMP

    Then I expect value of column "ISS_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ISS_ID FROM FT_T_ISID
    WHERE ID_CTXT_TYP = 'EISLSTID' and ISS_ID='${ISS_ID}'
    AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    AND END_TMS IS NULL
    """

  Scenario: TC_5: Data Verifications for TW\BONY\HIPORT : To verify DESC_USAGE_TYP (Description) in FT_T_ISDE table.
    Then I expect value of column "DESC_USAGE_TYP_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS DESC_USAGE_TYP_COUNT FROM FT_T_ISDE WHERE DESC_USAGE_TYP = 'PRIMARY'
     AND INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """

  Scenario: TC_6: Data Verifications for TW\BONY\HIPORT: To verify the ISIN

    Then I expect value of column "ISIN_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS ISIN_COUNT FROM FT_T_ISID
     WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID='${ISIN}'
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """

  Scenario: TC_7: Data Verifications for TW\BONY\HIPORT :To verify the SEDOL

    Then I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID
     WHERE ID_CTXT_TYP = 'SEDOL' AND ISS_ID='${SEDOL_CODE}'
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """

  Scenario: TC_8: Data Verifications for TW\BONY\HIPORT:To verify the CUSIP

    Then I expect value of column "CUSIP_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS CUSIP_COUNT FROM FT_T_ISID
     WHERE ID_CTXT_TYP = 'CUSIP' AND ISS_ID='${CUSIP_CODE}'
     AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
     AND END_TMS IS NULL
    """

  Scenario: TC_10: Data Verifications for TW\BONY\HIPORT:To verify the  Voting Rights Indicator

    Then I expect value of column "VOTING_RIGHTS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS VOTING_RIGHTS_COUNT FROM FT_T_EQCH
    WHERE VOTING_RIGHTS_TYP = (
                              CASE WHEN '${VOTING_RIGHTS_TYP_VALUE}' = 'Y' THEN 'V' ELSE 'N' END
                              )
    AND INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
    """

  Scenario: TC_11: Data Verifications for TW\BONY\HIPORT:To verify the  Next Conversion Date

    Then I expect value of column "PRD_START_DTE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS PRD_START_DTE_COUNT FROM FT_T_RIST WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND NXT_CNVR_PRD_START_DTE IS NULL
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    """

  Scenario: TC_12: Data Verifications for TW\BONY\HIPORT:To verify the U/L sec ID

    Then I expect value of column "REL_TYP_COUNT" in the below SQL query equals to "0":
      """
       SELECT COUNT(*) AS REL_TYP_COUNT FROM FT_T_RISS
       WHERE INSTR_ID=(
                      SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP ='EISLSTID' AND ISS_ID='${UL_SEC_ID}'
                      AND END_TMS IS NULL)
       AND RLD_ISS_FEAT_ID =
                            (SELECT RLD_ISS_FEAT_ID FROM FT_T_RIDF
                              WHERE INSTR_ID=
                              (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' AND ISS_ID='${UL_SEC_ID}'
                               AND END_TMS IS NULL)
                             AND REL_TYP='UNDERLYG')
       AND ISS_PART_RL_TYP='UNDLYING' AND PART_UNITS_TYP='ALL'
      """

  Scenario: TC_13: Data Verifications for M&G:To verify the Expiry Date,Contract Size,and Currency of Denomination

    Then I expect value of column "EXPIRY_DATE_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS EXPIRY_DATE_COUNT FROM FT_T_ISSU
     WHERE INSTR_ID=(
                     SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL
                    )
     AND MAT_EXP_TMS IS NULL AND ISS_UT_CQTY='${ISS_UT_CQTY}' AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
    """

  Scenario: TC_13: Data Verifications for TW\BONY\HIPORT:To verify the Expiry Date,Contract Size,and Currency of Denomination

    Then I expect value of column "EXPIRY_DATE_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS EXPIRY_DATE_COUNT FROM FT_T_ISSU WHERE
     INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' AND ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
     AND MAT_EXP_TMS IS NULL AND ISS_UT_CQTY='${ISS_UT_CQTY}' AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
    """

  Scenario: TC_14: Data Verifications for TW\BONY\HIPORT:To verify the CV Terms Numerator and CV Terms Denominator

    Then I expect value of column "CVTERMS_NUM_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS CVTERMS_NUM_COUNT FROM FT_T_RIST WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CNVR_RATIO_NUMER_NUM='${CNVR_RATIO_NUMER_NUM}'
      AND CNVR_RATIO_DENOM_NUM ='${CNVR_RATIO_DENOM_NUM}'
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    """

  Scenario: TC_15: Data Verifications for TW\BONY\HIPORT:To verify the Option type

    Then I expect value of column "OPT_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS OPT_COUNT FROM FT_T_OPCH  WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'EISLSTID' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CALL_PUT_TYP='${CALL_PUT_TYP}'
    """

  Scenario: TC_16: Data Verifications for TW\BONY\HIPORT:To verify the Security Type/Instrument Type

    Then I expect value of column "SECURITY_TYPE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS SECURITY_TYPE_COUNT FROM FT_T_INCL WHERE
      INDUS_CL_SET_ID = 'LGYSECTYPE' AND CL_VALUE = '${SEC_TYP}' AND END_TMS IS NULL
    """


  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
