#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC15 @fa_inbound @dmp_fundapps_regression
Feature: SCN015 : Security Regression: Load same unlisted security from BRS and RCR ,But Expiry date and contract size not present in BRS file

  1) Load the unlisted Aladdin file 10 without Expiry date and contract size and verify security created
  2) Load the same unlisted security RCR file again and verify separate security created
  3) Load the Aladdin file 10 again and verify there is no update

  Scenario: TC_1:Prerequisites before running actual tests

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20191219.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC15" with reference to "SECURITY_ID" column and assign to variables:
      | SECURITY_ID         | SECURITY_ID     |
      | DESCRIPTION         | DESCRIPTION     |
      | ISIN                | ISIN_ID         |
      | CUSIP               | CUSIP_ID        |
      | SEDOL               | SEDOL_CODE      |
      | EXPIRY_DATE         | MAT_EXP_TMS     |
      | CONTRACT_SIZE       | ISS_UT_CQTY     |
      | CURRENCY_OF_DENOMIN | DENOM_CURR_CODE |
      | SECURITY_TYPE/INSTR | SEC_TYP         |
      | SOURCE_BU_CODE      | SOURCE_CODE     |

    And I assign "esi_ADX_EOD_NON-ASIA_20190515_203007.sm.20190315 - 1.xml" to variable "INPUT_FILENAME"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    And  I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${SECURITY_ID}','${BCUSIP}'"

  Scenario: TC_2: security should created with BRS file load ,contact size and maturity date not present in BRS file

    Given I assign "esi_ADX_EOD_NON-ASIA_20190515_203007.sm.20190315 - 1.xml" to variable "INPUT_FILENAME_BRS"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with tagName "CURRENCY" to variable "BRS_CURRENCY"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with xpath "//CUSIP_ALIAS_set//CODE[text()='70']/../IDENTIFIER" to variable "BRS_ISIN_ID"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with xpath "//CUSIP2_set//CODE[text()='C']/../IDENTIFIER" to variable "BRS_SEDOL"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with tagName "CONTRACT_SIZE" to variable "BRS_CONTRACT_SIZE"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with tagName "DESC_INSTMT" to variable "BRS_DESCRIPTION"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with tagName "MATURITY" to variable "BRS_MAT_EXP_TMS"
    And I extract value from the xml file "${testdata.path}/TC15/${INPUT_FILENAME_BRS}" with tagName "SM_SEC_TYPE" to variable "BRS_SM_SEC_TYPE"
    And I assign "EIS_BRS_DMP_SECURITY" to variable "BRS_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC15" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I execute below query and extract values of "INSTR_ID" into same variables
        """
        SELECT INSTR_ID FROM FT_T_ISID
        WHERE ISS_ID = '${BCUSIP}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DATA_SRC_ID = 'BRS'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
        """
    Then I expect value of column "INSTR_ID_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS INSTR_ID_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
          )
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DENOM_CURR_CDE='${BRS_CURRENCY}'
        AND PREF_ISS_DESC='${BRS_DESCRIPTION}'
        AND ISS_UT_CQTY IS NULL
        AND MAT_EXP_TMS IS NULL
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: TC_3: Separate security should created with RCR file load

    Given I assign "BOCIEISLINSTMT20191219.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC15" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    #    Verify separate security created
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${SECURITY_ID}'
        AND INSTR_ID!='${INSTR_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
        """
    And I expect value of column "CONTRACT_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS CONTRACT_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${SECURITY_ID}' AND END_TMS IS NULL
          )
        AND ISS_UT_CQTY='${ISS_UT_CQTY}'
        AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
        AND MAT_EXP_TMS=TO_DATE('${MAT_EXP_TMS}','DD/MM/YYYY')
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: TC_4: securities should not be updated when same BRS file loaded again

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |


    Then I expect value of column "INSTR_ID_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS INSTR_ID_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
          )
        AND LAST_CHG_USR_ID='EIS_BRS_DMP_SECURITY'
        AND DENOM_CURR_CDE='${BRS_CURRENCY}'
        AND PREF_ISS_DESC='${BRS_DESCRIPTION}'
        AND ISS_UT_CQTY IS NULL
        AND MAT_EXP_TMS IS NULL
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

    And I expect value of column "RCR_CONTRACT_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS RCR_CONTRACT_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${SECURITY_ID}' AND END_TMS IS NULL
          )
        AND ISS_UT_CQTY='${ISS_UT_CQTY}'
        AND DENOM_CURR_CDE='${DENOM_CURR_CODE}'
        AND MAT_EXP_TMS=TO_DATE('${MAT_EXP_TMS}','DD/MM/YYYY')
        AND DATA_SRC_ID = '${SOURCE_CODE}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${SECURITY_ID}','${BCUSIP}'"