#https://jira.intranet.asia/browse/TOM-4415

@gc_interface_securities @gc_interface_orders
@dmp_regression_integrationtest
@dmp_fundapps_functional @sec_regression @sec_regression_TC23 @fa_inbound @dmp_fundapps_regression
Feature: SCN023:Security Regression: Load  unlisted security from RCR and BRS order files with different Description and Sec type

  1) Load the Unlisted Aladdin file 10 and verify security created
  2) Load the  Unlisted RCR file with different Description and Sec type and verify separate created

  Scenario: TC_1:Prerequisites before running actual tests
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/VendorHierarchy/testdata" to variable "testdata.path"
    And I assign "BOCIEISLINSTMT20191_23.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/TC23" with reference to "SECURITY_ID" column and assign to variables:
      | DESCRIPTION         | DESCRIPTION     |
      | SECURITY_ID         | ISS_ID          |
      | CUSIP               | CUSIP_ID        |
      | EXPIRY_DATE         | MAT_EXP_TMS     |
      | CONTRACT_SIZE       | ISS_UT_CQTY     |
      | CURRENCY_OF_DENOMIN | DENOM_CURR_CODE |
      | SECURITY_TYPE/INSTR | SEC_TYP         |
      | SOURCE_BU_CODE      | SOURCE_CODE     |

    And I assign "esi_orders.20190510_08_23.xml" to variable "INPUT_FILENAME_BRS"
    And I extract value from the xml file "${testdata.path}/TC23/${INPUT_FILENAME_BRS}" with tagName "CUSIP" to variable "BCUSIP"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}'"

  Scenario: TC_2: Separate security should created with BRS Orders feed

    Given I extract value from the xml file "${testdata.path}/TC23/${INPUT_FILENAME_BRS}" with tagName "CURRENCY" to variable "BRS_CURRENCY"
    And I extract value from the xml file "${testdata.path}/TC23/${INPUT_FILENAME_BRS}" with tagName "SEC_DESC1" to variable "BRS_DESCRIPTION"
    And I extract value from the xml file "${testdata.path}/TC23/${INPUT_FILENAME_BRS}" with tagName "MATURITY" to variable "BRS_MAT_EXP_TMS"
    And I extract value from the xml file "${testdata.path}/TC23/${INPUT_FILENAME_BRS}" with tagName "SM_SEC_TYPE" to variable "BRS_SM_SEC_TYPE"
    And I assign "EIS_BRS_DMP_ORDERS" to variable "BRS_LAST_CHG_USR"
    When I copy files below from local folder "${testdata.path}/TC23" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BRS} |
    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS} |
      | MESSAGE_TYPE  |                       |
      | BUSINESS_FEED | EIS_BF_BRS_ORDERS     |
 #    Verify separate security created
    Then I execute below query and extract values of "INSTR_ID" into same variables
        """
        SELECT INSTR_ID FROM FT_T_ISID
        WHERE ISS_ID = '${BCUSIP}'
        AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
        AND LAST_CHG_USR_ID='${BRS_LAST_CHG_USR}'
        AND DATA_SRC_ID = 'BRS'
        AND END_TMS IS NULL
        """
    And I expect value of column "SECURITY_COUNT" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS SECURITY_COUNT FROM FT_T_ISSU
        WHERE INSTR_ID IN (
          SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
          )
        AND LAST_CHG_USR_ID='${BRS_LAST_CHG_USR}'
        AND DENOM_CURR_CDE='${BRS_CURRENCY}'
        AND PREF_ISS_DESC='${BRS_DESCRIPTION}'
        AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
        AND END_TMS IS NULL
      """

  Scenario: TC_3: Separate security should created with  RCR feed
    RCR file with with Description and Sec type
    Given I assign "BOCIEISLINSTMT20191_23.csv" to variable "INPUT_FILENAME"
    When I copy files below from local folder "${testdata.path}/TC23" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    When I process files with below parameters and wait for the job to be completed
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
        AND END_TMS IS NULL
      """

  Scenario: Clear the data after tests
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${SECURITY_ID}','${BCUSIP}'"