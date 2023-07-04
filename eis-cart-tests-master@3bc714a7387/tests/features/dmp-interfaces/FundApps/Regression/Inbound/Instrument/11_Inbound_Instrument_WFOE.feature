#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
#Dev Ticket     : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket : https://jira.intranet.asia/browse/TOM-4265
#https://jira.intranet.asia/browse/EISDEV-5400 - Changes to load GP files directly. The security connector will load RCR as well GP files in DMP
#https://jira.intranet.asia/browse/EISDEV-5399 - GSDMFiltering where CLIENT_SEC_TYPE is null

@dmp_regression_unittest
@dmp_fundapps_regression
@tom_4265 @11_inbound_gp_wfoe @dmp_fundapps_functional @fund_apps_instrument @fa_inbound
@eisdev_5400 @fundapps_security_inbound_gp @eisdev_5539

Feature: To verify that DMP receive the inbound instrument file data from the entity WFOE
  All the fields should be updated in dmp as per the inbound instrument GP file

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

    And I assign "WFOE_EISL_INSTMT_20180219.csv" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID     | ISS_ID          |
      | ISIN          | ISIN            |
      | SEDOL         | SEDOL_CODE      |
      | CUSIP         | CUSIP_CODE      |
      | MATURITY      | MAT_EXP_TMS     |
      | CONTRACT_SIZE | ISS_UT_CQTY     |
      | CURRENCY      | DENOM_CURR_CODE |

    And I assign "WFOE" to variable "SOURCE_CODE"
    And I assign "N" to variable "VOTING_RIGHTS_TYP_VALUE"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"

  Scenario: TC_2: Load WFOE file 'WFOE_EISL_INSTMT_20180219.csv
    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC_3: Data Verifications for 'WFOE' :To verify  the inbound instrument file load in to DMP  from the entity 'WFOE'
    Then I expect value of column "JOB_ID" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS JOB_ID FROM FT_T_JBLG WHERE JOB_STAT_TYP='CLOSED' AND TASK_SUCCESS_CNT = 1 AND TASK_FILTERED_CNT = 1
      AND JOB_MSG_TYP='EIS_MT_WFOE_DMP_SECURITY' AND JOB_ID = '${JOB_ID}' AND JOB_INPUT_TXT LIKE '%${INPUT_FILENAME}'
      """

  Scenario: TC_4: Data Verifications for 'WFOE: To verify the Security_id from file in to DMP

    Then I expect value of column "ISS_ID" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISS_ID FROM FT_T_ISID
      WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}'
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
      AND END_TMS IS NULL
      """

  Scenario: TC_5: Data Verifications for 'WFOE :To verify DESC_USAGE_TYP (Description) in FT_T_ISDE table.
    Then I expect value of column "DESC_USAGE_TYP_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS DESC_USAGE_TYP_COUNT FROM FT_T_ISDE WHERE DESC_USAGE_TYP = 'PRIMARY'
       AND INSTR_ID = (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      """

  Scenario: TC_6: Data Verifications for 'WFOE: To verify the ISIN 

    Then I expect value of column "ISIN_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS ISIN_COUNT FROM FT_T_ISID
       WHERE ID_CTXT_TYP = 'ISIN' AND ISS_ID='${ISIN}'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

  Scenario: TC_7: Data Verifications for 'WFOE :To verify the SEDOL

    Then I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID
       WHERE ID_CTXT_TYP = 'SEDOL' AND ISS_ID='${SEDOL_CODE}'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

  Scenario: TC_8: Data Verifications for 'WFOE:To verify the CUSIP

    Then I expect value of column "CUSIP_COUNT" in the below SQL query equals to "0":
    """
     Select COUNT(*) AS CUSIP_COUNT FROM FT_T_ISID WHERE ID_CTXT_TYP = 'CUSIP' AND ISS_ID='${CUSIP_CODE}' AND END_TMS IS NULL
    """

  Scenario: TC_9: Data Verifications for WFOE:To verify the  Source BU Code

    Then I expect value of column "DATA_SRC_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS DATA_SRC_COUNT FROM FT_T_DSRC WHERE DATA_SRC_NME='${SOURCE_CODE}' AND END_TMS IS NULL
    """

  Scenario: TC_10: Data Verifications for :To verify the  Voting Rights Indicator

    Then I expect value of column "VOTING_RIGHTS_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS VOTING_RIGHTS_COUNT FROM FT_T_EQCH WHERE VOTING_RIGHTS_TYP = (CASE WHEN '${VOTING_RIGHTS_TYP_VALUE}' = 'Y' THEN 'V' ELSE 'N' END)
      AND INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
    """

  Scenario: TC_11: Data Verifications for WFOE:To verify the  Next Conversion Date

    Then I expect value of column "PRD_START_DTE_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS PRD_START_DTE_COUNT FROM FT_T_RIST
      WHERE INSTR_ID=(
                      SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL
                     )
      AND NXT_CNVR_PRD_START_DTE IS NULL
    """

  Scenario: TC_12: Data Verifications for WFOE:To verify the U/L sec ID

    Then I expect value of column "UL_SEC_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS UL_SEC_COUNT FROM FT_T_RISS WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND ISS_PART_RL_TYP='UNDLYING' AND PART_UNITS_TYP='ALL'
    """

  Scenario: TC_13: Data Verifications for WFOE:To verify the Expiry Date,Contract Size,Currency of Denomination and Security Type/Instrument Type  and

    Then I expect value of column "EXPIRY_DATE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXPIRY_DATE_COUNT FROM FT_T_ISSU WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND MAT_EXP_TMS IS NULL AND ISS_UT_CQTY IS NULL AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
    """

  Scenario: TC_14: Data Verifications for WFOE:To verify the CV Terms Numerator and CV Terms Denominator

    Then I expect value of column "CVTERMS_NUM_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS CVTERMS_NUM_COUNT FROM FT_T_RIST WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CNVR_RATIO_NUMER_NUM IS NULL
      AND CNVR_RATIO_DENOM_NUM IS NULL
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    """

  Scenario: TC_15: Data Verifications for WFOE:To verify the Option type

    Then I expect value of column "OPT_COUNT" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS OPT_COUNT FROM FT_T_OPCH  WHERE
      INSTR_ID=(SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'WFOECODE' and ISS_ID='${ISS_ID}' AND END_TMS IS NULL)
      AND CALL_PUT_TYP IS NULL
    """

  Scenario: TC_16: Data Verifications for M&G:To verify the Security Type/Instrument Type

    Then I expect value of column "SECURITY_TYPE_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS SECURITY_TYPE_COUNT FROM FT_T_INCL WHERE
      INDUS_CL_SET_ID = 'WFOESCTYP' AND CL_VALUE = 'COM' AND END_TMS IS NULL
    """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_CODE}','${ISIN}'"