#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC25 @fa_inbound @dmp_fundapps_regression
Feature: SCN025 : Security Regression: Load the same listed security from RCR and BNP ,But different ISIN,CUSIP,Maturity date,Sec type and Description

  1) Load the RCR file and verify security created
  2) Load the BNP Security File with different ISIN , CUSIP,Maturity date,Sec type and Description and verify same security updated with BNP file details
  3) Load the same RCR file again and verify there is no update

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20190513_25.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC25" with reference to "SECURITY_ID" column and assign to variables:
      | DESCRIPTION         | DESCRIPTION     |
      | SECURITY_ID         | ISS_ID          |
      | ISIN                | ISIN_ID         |
      | CUSIP               | CUSIP_ID        |
      | SEDOL               | SEDOL_CODE      |
      | EXPIRY_DATE         | MAT_EXP_TMS     |
      | CONTRACT_SIZE       | ISS_UT_CQTY     |
      | CURRENCY_OF_DENOMIN | DENOM_CURR_CODE |
      | SECURITY_TYPE/INSTR | SEC_TYP         |
      | SOURCE_BU_CODE      | SOURCE_CODE     |

    And I assign "ESISODP_SEC_1_20190510_25.out" to variable "BNP_INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${BNP_INPUT_FILENAME}" in local folder "${testdata.path}/TC25" and assign to variables:
      | INSTR_ID          | BNP_INSTR_ID          |
      | INSTR_LONG_NAME   | BNP_INSTR_LONG_NAME   |
      | ISIN              | BNP_ISIN              |
      | CUSIP             | BNP_CUSIP             |
      | SEDOL             | BNP_SEDOL             |
      | HIP_SECURITY_CODE | BNP_HIP_SECURITY_CODE |
      | INSTR_TYPE        | BNP_INSTR_TYPE        |
      | SOURCE_ID         | BNP_SOURCE_ID         |
      | ISSUE_CCY         | BNP_ISSUE_CCY         |
      | MATURITY_DATE     | BNP_MATURITY_DATE     |
      | ISSUE_DATE        | BNP_ISSUE_DATE        |

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_ID}','${ISIN_ID}','${BNP_INSTR_ID}','${BNP_ISIN}','${BNP_SEDOL}','${BNP_HIP_SECURITY_CODE}'"

  Scenario: TC_2:New Security Creation with RCR feed:New Security should be created when Load listed security from RCR

    Given I assign "BOCIEISLINSTMT20190513_25.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC25" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I execute below query and extract values of "INSTR_ID" into same variables
        """
        SELECT INSTR_ID FROM FT_T_ISID
        WHERE ISS_ID = '${ISIN_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND END_TMS IS NULL
        """
    And I expect value of column "SEDOL_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS SEDOL_COUNT FROM FT_T_ISID
     WHERE ISS_ID='${SEDOL_CODE}'
     AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
     AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
     AND DATA_SRC_ID = '${SOURCE_CODE}'
     AND ID_CTXT_TYP='SEDOL'
     AND END_TMS IS NULL
    """
    And I expect value of column "CUSIP_COUNT" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS CUSIP_COUNT FROM FT_T_ISID
     WHERE ISS_ID='${CUSIP_ID}'
     AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
     AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
     AND DATA_SRC_ID = '${SOURCE_CODE}'
     AND END_TMS IS NULL
    """

    And I expect value of column "RCR_SEC_TYPE_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS RCR_SEC_TYPE_COUNT FROM FT_T_ISCL
        WHERE INSTR_ID='${INSTR_ID}'
        AND INDUS_CL_SET_ID='BOCISCTYPE'
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND CL_VALUE='${SEC_TYP}'
        AND END_TMS IS NULL
      """
    And I expect value of column "RCR_DESCRIPTION_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS RCR_DESCRIPTION_COUNT FROM FT_T_ISSU
      WHERE INSTR_ID='${INSTR_ID}'
       AND PREF_ISS_DESC='${DESCRIPTION}'
      AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
      AND MAT_EXP_TMS=TO_DATE('${MAT_EXP_TMS}','DD/MM/YYYY')
      AND END_TMS IS NULL
    """

  Scenario: TC_3: Security should be updated with ISIN ,CUSIP and Maturity date when same listed security loaded from BNP

    Given I assign "EIS_BNP_DMP_SECURITY" to variable "BNP_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC25" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BNP_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |
      | BUSINESS_FEED |                       |

    #verify same security (INSTR_ID) updated with BNP parameters
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${BNP_INSTR_ID}'
        AND INSTR_ID='${INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND DATA_SRC_ID = 'BNP'
        AND END_TMS IS NULL
        """
    And I expect value of column "BNP_SEDOL_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS BNP_SEDOL_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BNP_SEDOL}'
       AND INSTR_ID='${INSTR_ID}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
       AND DATA_SRC_ID = 'BNP'
       AND ID_CTXT_TYP='SEDOL'
       AND END_TMS IS NULL
      """

    And I expect value of column "BNP_CUSIP_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS BNP_CUSIP_COUNT FROM FT_T_ISID
     WHERE ISS_ID='${BNP_CUSIP}'
     AND INSTR_ID='${INSTR_ID}'
     AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
     AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
     AND DATA_SRC_ID = 'BNP'
     AND ID_CTXT_TYP='CUSIP'
     AND END_TMS IS NULL
    """


    And I expect value of column "BNP_SEC_TYPE_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BNP_SEC_TYPE_COUNT FROM FT_T_ISCL
        WHERE INSTR_ID='${INSTR_ID}'
        AND INDUS_CL_SET_ID='BNPSECTYPE'
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND DATA_SRC_ID = 'BNP'
        AND CL_VALUE='${BNP_INSTR_TYPE}'
        AND END_TMS IS NULL
      """

    And I expect value of column "BNP_DESCRIPTION_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BNP_DESCRIPTION_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID='${INSTR_ID}'
        AND PREF_ISS_DESC='${BNP_INSTR_LONG_NAME}'
        AND DENOM_CURR_CDE='${BNP_ISSUE_CCY}'
        AND MAT_EXP_TMS=TO_DATE('${BNP_MATURITY_DATE}','YYYY-MON-DD')
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: TC_4: Security no update with RCR feed: Security should not be updated when load the same RCR file again

    Given I assign "BOCIEISLINSTMT20190513_25.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC25" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${BNP_ISIN}'
        AND INSTR_ID='${INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
        AND DATA_SRC_ID = 'BNP'
        AND END_TMS IS NULL
        """
    And I expect value of column "BNP_SEDOL_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS BNP_SEDOL_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BNP_SEDOL}'
       AND INSTR_ID='${INSTR_ID}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
       AND DATA_SRC_ID = 'BNP'
       AND ID_CTXT_TYP='SEDOL'
       AND END_TMS IS NULL
      """

    And I expect value of column "BNP_CUSIP_COUNT" in the below SQL query equals to "1":
      """
         SELECT COUNT(*) AS BNP_CUSIP_COUNT FROM FT_T_ISID
         WHERE ISS_ID='${BNP_CUSIP}'
         AND INSTR_ID='${INSTR_ID}'
         AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
         AND LAST_CHG_USR_ID='${BNP_LAST_CHG_USR}'
         AND DATA_SRC_ID = 'BNP'
         AND ID_CTXT_TYP='CUSIP'
         AND END_TMS IS NULL
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${SEDOL_CODE}','${CUSIP_ID}','${ISIN_ID}','${BNP_INSTR_ID}','${BNP_ISIN}','${BNP_SEDOL}','${BNP_HIP_SECURITY_CODE}'"
