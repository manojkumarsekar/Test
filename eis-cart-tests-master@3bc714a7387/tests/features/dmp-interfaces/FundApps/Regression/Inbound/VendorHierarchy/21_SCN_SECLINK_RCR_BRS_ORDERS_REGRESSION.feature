#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities @gc_interface_orders
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC21 @fa_inbound @dmp_fundapps_regression
Feature: SCN21: Security Regression: Load the same listed security from RCR and BRS Orders without ISIN and CUSIP

  1) Load the Aladdin Orders file without ISIN and CUSIP and verify security created
  2) Load the  RCR file with ISIN and CUSIP and verify same security updated with RCR ISIN, CUSIP details
  3) Load the same Aladdin orders file again and verify there no is update

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20191021.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC21" with reference to "SECURITY_ID" column and assign to variables:
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

    And I assign "esi_orders.20190510_21.xml" to variable "INPUT_FILENAME_BRS"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "SEDOL" to variable "BRS_SEDOL"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "CUSIP" to variable "BCUSIP"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${CUSIP_ID}','${SEDOL_CODE}','${BRS_SEDOL}','${BCUSIP}'"

  Scenario: TC_2: Security Creation with BRS feed: Security should be updated when same listed security from BRS Orders

    Given I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "CURRENCY" to variable "BRS_CURRENCY"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "SEDOL" to variable "BRS_SEDOL"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "SEC_DESC1" to variable "BRS_DESCRIPTION"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "MATURITY" to variable "BRS_MAT_EXP_TMS"
    And I extract value from the xml file "${testdata.path}/TC21/${INPUT_FILENAME_BRS}" with tagName "SM_SEC_TYPE" to variable "BRS_SM_SEC_TYPE"
    And I assign "EIS_BRS_DMP_ORDERS" to variable "BRS_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC21" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS} |
      | MESSAGE_TYPE  |                       |
      | BUSINESS_FEED | EIS_BF_BRS_ORDERS     |
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
         SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
         WHERE ISS_ID = '${BRS_SEDOL}'
         AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
         AND LAST_CHG_USR_ID='${BRS_LAST_CHG_USR}'
         AND DATA_SRC_ID = 'BRS'
         AND ID_CTXT_TYP='SEDOL'
         AND END_TMS IS NULL
        """

    And I expect value of column "BRS_CURRENCY_VAL" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS BRS_CURRENCY_VAL FROM FT_T_ISSU
      WHERE INSTR_ID=(
                      SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BRS_SEDOL}' AND END_TMS IS NULL
                     )
      AND DENOM_CURR_CDE='${BRS_CURRENCY}'
      AND END_TMS IS NULL

    """

  Scenario: TC_3: Security should updated with ISIN and CUSIP with RCR feed

    Given I assign "BOCIEISLINSTMT20191021.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC21" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_SECURITY |
      | BUSINESS_FEED |                          |
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
        WHERE ISS_ID = '${ISIN_ID}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='EIS_RCRLBU_DMP_SECURITY'
        AND DATA_SRC_ID = 'BOCI'
        AND END_TMS IS NULL
        """

  Scenario: TC_4: Security no with same BRS feed: Security should not be updated when same listed security from BRS Orders

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS} |
      | MESSAGE_TYPE  |                       |
      | BUSINESS_FEED | EIS_BF_BRS_ORDERS     |
    Then I expect value of column "SECURITY_ID_COUNT" in the below SQL query equals to "1":
        """
         SELECT COUNT(*) AS SECURITY_ID_COUNT FROM FT_T_ISID
         WHERE ISS_ID = '${BRS_SEDOL}'
         AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
         AND LAST_CHG_USR_ID='${BRS_LAST_CHG_USR}'
         AND DATA_SRC_ID = 'BRS'
         AND ID_CTXT_TYP='SEDOL'
         AND END_TMS IS NULL
        """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${CUSIP_ID}','${SEDOL_CODE}','${BRS_SEDOL}'"