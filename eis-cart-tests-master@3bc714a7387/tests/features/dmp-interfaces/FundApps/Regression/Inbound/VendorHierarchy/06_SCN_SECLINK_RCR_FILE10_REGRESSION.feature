#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC06 @fa_inbound @dmp_fundapps_regression
Feature: SCN06:Security Regression:Load same listed security from RCR and BRS when ISIN is not present in RCR file but present in BRS file

  1) Load the RCR file without ISIN and verify Security created
  2) Load the Aladdin file 10 with ISIN and verify same Security Updated all BRS details
  3) Load the same RCR file again and verify security not updated

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20181218.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC6" with reference to "SECURITY_ID" column and assign to variables:
      | DESCRIPTION         | DESCRIPTION     |
      | ISIN                | ISIN_ID         |
      | CUSIP               | CUSIP_ID        |
      | SEDOL               | SEDOL_CODE      |
      | EXPIRY_DATE         | MAT_EXP_TMS     |
      | CONTRACT_SIZE       | ISS_UT_CQTY     |
      | CURRENCY_OF_DENOMIN | DENOM_CURR_CODE |
      | SECURITY_TYPE/INSTR | SEC_TYP         |
      | SOURCE_BU_CODE      | SOURCE_CODE     |

    And I assign "esi_ADX_EOD_NON-ASIA_20190315_203007.sm.20190315 - 2.xml" to variable "INPUT_FILENAME_BRS"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with xpath "//CUSIP_ALIAS_set//CODE[text()='70']/../IDENTIFIER" to variable "BRS_ISIN_ID"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "BRS_SEDOL"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with xpath "//CUSIP2_record//CODE[text()='A']/../IDENTIFIER" to variable "BRS_CUSIP"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "CUSIP" to variable "BCUSIP"
    And  I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP_ID}','${BCUSIP}','${SEDOL_CODE}','${BRS_ISIN_ID}'"

  Scenario: TC_2:New Security Creation with RCR feed:New Security should be created when Load listed security from RCR ISIN is not present

    Given I assign "BOCIEISLINSTMT20181218.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC6" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I execute below query and extract values of "INSTR_ID" into same variables
        """
          SELECT INSTR_ID FROM FT_T_ISID
          WHERE ISS_ID='${CUSIP_ID}'
          AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
          AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
          AND DATA_SRC_ID = '${SOURCE_CODE}'
          AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
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
         AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
      """

    Then I expect value of column "CONTRACT_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS CONTRACT_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${SEDOL_CODE}' AND ID_CTXT_TYP='BOCICODE' AND END_TMS IS NULL
                       )
        AND ISS_UT_CQTY='${ISS_UT_CQTY}'
        AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
        AND MAT_EXP_TMS=TO_DATE('${MAT_EXP_TMS}','DD/MM/YYYY')
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """
    And I expect value of column "RCR_SEC_TYPE_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS RCR_SEC_TYPE_COUNT FROM FT_T_ISCL
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${SEDOL_CODE}' AND ID_CTXT_TYP='BOCICODE' AND END_TMS IS NULL
                       )
        AND INDUS_CL_SET_ID='BOCISCTYPE'
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND CL_VALUE='${SEC_TYP}'
        AND END_TMS IS NULL
      """

  Scenario: TC_3: Security update with BRS file- Security should get updated with parameters from BRS File

    Given I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "CURRENCY" to variable "BRS_CURRENCY"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "CONTRACT_SIZE" to variable "BRS_CONTRACT_SIZE"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "DESC_INSTMT" to variable "BRS_DESCRIPTION"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "MATURITY" to variable "BRS_MAT_EXP_TMS"
    And I extract value from the xml file "${testdata.path}/TC6/${INPUT_FILENAME_BRS}" with tagName "SM_SEC_TYPE" to variable "BRS_SM_SEC_TYPE"
    And I assign "EIS_BRS_DMP_SECURITY" to variable "BRS_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC6" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |
    Then I expect value of column "ISIN_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS ISIN_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${BRS_ISIN_ID}'
        AND INSTR_ID='${INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DATA_SRC_ID = 'BRS'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND ID_CTXT_TYP='ISIN'
        AND END_TMS IS NULL
        """
    And I expect value of column "BRS_SEDOL_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS BRS_SEDOL_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BRS_SEDOL}'
        AND INSTR_ID='${INSTR_ID}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
       AND DATA_SRC_ID = 'BRS'
       AND ID_CTXT_TYP='SEDOL'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

    And I expect value of column "BRS_CUSIP_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS BRS_CUSIP_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BCUSIP}'
       AND INSTR_ID='${INSTR_ID}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
       AND DATA_SRC_ID = 'BRS'
       AND ID_CTXT_TYP='BCUSIP'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

    And I expect value of column "BRS_CONTRACT_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BRS_CONTRACT_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BRS_ISIN_ID}' AND END_TMS IS NULL
                       )
        AND ISS_UT_CQTY='${BRS_CONTRACT_SIZE}'
        AND DENOM_CURR_CDE='${BRS_CURRENCY}'
        AND MAT_EXP_TMS=TO_DATE('${BRS_MAT_EXP_TMS}','MM/DD/YYYY')
        AND PREF_ISS_DESC='${BRS_DESCRIPTION}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

    And I expect value of column "BRS_SEC_TYPE_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BRS_SEC_TYPE_COUNT FROM FT_T_ISCL
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BRS_ISIN_ID}' AND END_TMS IS NULL
                       )
        AND INDUS_CL_SET_ID='SECTYPE'
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DATA_SRC_ID = 'BRS'
        AND CL_VALUE='${BRS_SM_SEC_TYPE}'
        AND END_TMS IS NULL
      """

  Scenario: TC_4:Security no update with RCR feed: Security should not be updated when load the same RCR file again

    Given I assign "BOCIEISLINSTMT20181218.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC6" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I expect value of column "ISIN_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS ISIN_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${BRS_ISIN_ID}'
        AND INSTR_ID='${INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DATA_SRC_ID = 'BRS'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND ID_CTXT_TYP='ISIN'
        AND END_TMS IS NULL
        """

    And I expect value of column "BRS_SEDOL_COUNT" in the below SQL query equals to "1":
      """
       Select COUNT(*) AS BRS_SEDOL_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BRS_SEDOL}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
       AND DATA_SRC_ID = 'BRS'
       AND ID_CTXT_TYP='SEDOL'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

    And I expect value of column "BRS_CUSIP_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS BRS_CUSIP_COUNT FROM FT_T_ISID
       WHERE ISS_ID='${BCUSIP}'
       AND INSTR_ID='${INSTR_ID}'
       AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
       AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
       AND DATA_SRC_ID = 'BRS'
       AND ID_CTXT_TYP='BCUSIP'
       AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
       AND END_TMS IS NULL
      """

    And I expect value of column "BRS_CONTRACT_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BRS_CONTRACT_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BRS_ISIN_ID}' AND END_TMS IS NULL
                       )
        AND ISS_UT_CQTY='${BRS_CONTRACT_SIZE}'
        AND DENOM_CURR_CDE='${BRS_CURRENCY}'
        AND MAT_EXP_TMS=TO_DATE('${BRS_MAT_EXP_TMS}','MM/DD/YYYY')
        AND PREF_ISS_DESC='${BRS_DESCRIPTION}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

    And I expect value of column "BRS_SEC_TYPE_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS BRS_SEC_TYPE_COUNT FROM FT_T_ISCL
        WHERE INSTR_ID=(
                        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BRS_ISIN_ID}' AND END_TMS IS NULL
                       )
        AND INDUS_CL_SET_ID='SECTYPE'
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DATA_SRC_ID = 'BRS'
        AND CL_VALUE='${BRS_SM_SEC_TYPE}'
        AND END_TMS IS NULL
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP_ID}','${BCUSIP}','${SEDOL_CODE}','${BRS_ISIN_ID}'"
