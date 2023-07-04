#https://jira.pruconnect.net/browse/EISDEV-6128
#https://collaborate.pruconnect.net/display/EISTOMR4/FA-IN-SMF-LBURCR-DMP-Fund-File
#EISDEV-6128 : as part of this ticket M&G Flag mapping has been removed. Removing the validation check from Feature

@gc_interface_funds
@dmp_regression_unittest
@dmp_rcrlbu_robo_funds @dmp_fundapps_functional @fund_apps_funds @eisdev_6128
Feature: EISDEV-6128: Funds RCRLBU ROBO file load (Golden Source)

  1) Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.
  3) Load the fund the from the fund, fund id and its attributes from the file and verify the loaded data.

  #Prerequisites
  Scenario: TC_1: Clear ACID data and assign variables to test new fund and fund indentifiers creations
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Funds" to variable "testdata.path"
    And I assign "ROBOEISLFUNDLE20200421.CSV" to variable "INPUT_FILENAME"
    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Fund Id" column and assign to variables:
      | Fund Id                                        | ACT_ID    |
      | Fund Vehicle Type                              | FVT       |
      | Pru Group LE ID                                | PRU_LE_ID |
      | Investment Discretion LE ID                    | INV_LE_ID |
      | Investment Discretion LE VR Discretion         | LE_VR     |
      | Investment Discretion LE Investment Discretion | LE_INV    |

    #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"

    #Setting INVLOC according to Data Source
    And I assign "HK" to variable "INVLOC"

    And I execute below query to "remove the ROBO Fund IDs from ACID table"
    """
    ${testdata.path}/sql/ClearACID.sql
    """

  Scenario: TC_2: File load for RCRLBU Fund for Data Source ROBO

    Given I assign "ROBOEISLFUNDLE20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_3: Verification of Fund Identifiers
    #Verification of ACID table for the fund loaded with required data from file
    Then I expect value of column "CODE_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as CODE_COUNT FROM FT_T_ACID
      WHERE ACCT_ALT_ID = '${ACT_ID}'
      AND ACCT_ID_CTXT_TYP = '${ACCT_ID_CTXT}'
      AND END_TMS IS NULL
      """

    #Verification of ACID for IRPID for the fund loaded with required data from file
    Then I expect value of column "IRP_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as IRP_COUNT FROM FT_T_ACID
      WHERE ACCT_ALT_ID = '${ACT_ID}'
      AND ACCT_ID_CTXT_TYP = 'IRPID'
      AND END_TMS IS NULL
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

  Scenario: TC_4: Verification of Fund Vehicle type, LE VR Discretion and Investment VR Discretion
    #Verification of ACCL for Fund Vehicle type for the fund loaded with required data from file
    Then I expect value of column "FVT_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as FVT_COUNT FROM FT_T_ACCL
      WHERE END_TMS IS NULL
      AND CL_VALUE = UPPER('${FVT}')
      AND INDUS_CL_SET_ID = 'FNDVHCLTYP'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

    #Verification of ACCL for LE VR Discretion for the fund loaded with required data from file
    Then I expect value of column "LEVR_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as LEVR_COUNT FROM FT_T_ACCL
      WHERE END_TMS IS NULL
      AND CL_VALUE = '${LE_VR}'
      AND INDUS_CL_SET_ID = 'LEVRDISC'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

    #Verification of ACCL for Investment VR Discretion for the fund loaded with required data from file
    Then I expect value of column "LEIN_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as LEIN_COUNT FROM FT_T_ACCL
      WHERE END_TMS IS NULL
      AND CL_VALUE = '${LE_INV}'
      AND INDUS_CL_SET_ID = 'LEINDISC'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

  Scenario: TC_5: Verification of flags
    #Verification of ACST for SSH Flag for the fund loaded with required data from file
    Then I expect value of column "SSH_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as SSH_COUNT FROM FT_T_ACST
      WHERE END_TMS IS NULL
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND STAT_DEF_ID = 'SSHFLAG'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

    #Verification of ACST for PPM Flag for the fund loaded with required data from file
    Then I expect value of column "PPM_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as PPM_COUNT FROM FT_T_ACST
      WHERE END_TMS IS NULL
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND STAT_DEF_ID = 'PPMFLAG'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

    #Verification of ACST for NPP Flag for the fund loaded with required data from file
    Then I expect value of column "NPP_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as NPP_COUNT FROM FT_T_ACST
      WHERE END_TMS IS NULL
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND STAT_DEF_ID = 'NPP'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

  Scenario: TC_6: Verification of Currency data
    #Verification of FNCH for Base Currency for the fund loaded with required data from file
    Then I expect value of column "CURR_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as CURR_COUNT FROM FT_T_FNCH
      WHERE END_TMS IS NULL
      AND FUND_CURR_CDE = 'USD'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

  Scenario: TC_7: Verification of location data
    #Verification of Location data for the fund loaded with required data from file
    Then I expect value of column "INVLOC_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as INVLOC_COUNT FROM FT_T_ACGU
      WHERE END_TMS IS NULL
      AND GU_ID = '${INVLOC}'
      AND GU_CNT = '1'
      AND GU_TYP = 'COUNTRY'
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

  Scenario: TC_8: Verification of LE data
    #Verification of FRAP for PRU_GROUP for the fund loaded with required data from file
    Then I expect value of column "PRGRP_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as PRGRP_COUNT FROM FT_T_FRAP
      WHERE END_TMS IS NULL
      AND FINSRL_TYP = 'PRUGROUP'
      AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID = '${PRU_LE_ID}' AND FINS_ID_CTXT_TYP = 'RCRLBULEID' AND END_TMS IS NULL)
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """

    #Verification of FRAP for Investment Manager for the fund loaded with required data from file
    Then I expect value of column "INVMGR_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as INVMGR_COUNT FROM FT_T_FRAP
      WHERE END_TMS IS NULL
      AND FINSRL_TYP = 'INVMGR'
      AND INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID = '${INV_LE_ID}' AND FINS_ID_CTXT_TYP = 'RCRLBULEID' AND END_TMS IS NULL)
      AND ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID ='${ACT_ID}' AND ACCT_ID_CTXT_TYP='${ACCT_ID_CTXT}' AND END_TMS IS NULL)
      """