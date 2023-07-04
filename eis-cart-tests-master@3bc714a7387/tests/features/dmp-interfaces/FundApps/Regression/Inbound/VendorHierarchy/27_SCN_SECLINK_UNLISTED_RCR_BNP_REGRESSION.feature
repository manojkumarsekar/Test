#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC27 @fa_inbound @dmp_fundapps_regression
Feature: SCN027: Security Regression: Load unlisted securities from RCR and BNP files

  1) Load the Unlisted BNP security and verify security created
  2) Load the same Unlisted security RCR file with different Description and Sec type and verify separate created

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20190513_27.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC27" with reference to "SECURITY_ID" column and assign to variables:
      | DESCRIPTION         | DESCRIPTION     |
      | SECURITY_ID         | ISS_ID          |
      | EXPIRY_DATE         | MAT_EXP_TMS     |
      | CONTRACT_SIZE       | ISS_UT_CQTY     |
      | CURRENCY_OF_DENOMIN | DENOM_CURR_CODE |
      | SECURITY_TYPE/INSTR | SEC_TYP         |
      | SOURCE_BU_CODE      | SOURCE_CODE     |

    And I assign "ESISODP_SEC_1_20190510_27.out" to variable "BNP_INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${BNP_INPUT_FILENAME}" in local folder "${testdata.path}/TC27" and assign to variables:
      | INSTR_ID          | BNP_INSTR_ID          |
      | INSTR_LONG_NAME   | BNP_INSTR_LONG_NAME   |
      | CUSIP             | BNP_CUSIP             |
      | HIP_SECURITY_CODE | BNP_HIP_SECURITY_CODE |
      | SOURCE_ID         | BNP_SOURCE_ID         |
      | ISSUE_CCY         | BNP_ISSUE_CCY         |
      | MATURITY_DATE     | BNP_MATURITY_DATE     |
      | ISSUE_DATE        | BNP_ISSUE_DATE        |

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BNP_INSTR_ID}','${BNP_HIP_SECURITY_CODE}'"

  Scenario: TC_2: Separate security should created with BNP unlisted Security load

    Given I assign "EIS_BNP_DMP_SECURITY" to variable "BNP_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC27" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BNP_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |
      | BUSINESS_FEED |                       |

   #verify security (INSTR_ID) created
    Then I execute below query and extract values of "INSTR_ID" into same variables
        """
        SELECT INSTR_ID FROM FT_T_ISID
        WHERE ISS_ID = '${BNP_INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND DATA_SRC_ID = 'BNP'
        AND END_TMS IS NULL
        """
    And I expect value of column "BNP_DESCRIPTION_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BNP_DESCRIPTION_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID = '${INSTR_ID}'
        AND PREF_ISS_DESC='${BNP_INSTR_LONG_NAME}'
        AND DENOM_CURR_CDE='${BNP_ISSUE_CCY}'
        AND MAT_EXP_TMS=TO_DATE('${BNP_MATURITY_DATE}','YYYY-MON-DD')
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: TC_3: Separate security should created with  RCR feed
  RCR file with different Description and Sec type

    Given I assign "BOCIEISLINSTMT20190513_27.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC27" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
        WHERE INSTR_ID !='${INSTR_ID}'
        AND ISS_ID = '${ISS_ID}'
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = 'BOCI'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
        """
    And I expect value of column "DESCRIPTION_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS DESCRIPTION_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISS_ID}' AND END_TMS IS NULL
          )
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
        AND PREF_ISS_DESC='${DESCRIPTION}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND INSTR_ID !='${INSTR_ID}'
        AND END_TMS IS NULL
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BNP_INSTR_ID}','${BNP_HIP_SECURITY_CODE}'"