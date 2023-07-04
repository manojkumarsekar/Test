#https://jira.intranet.asia/browse/TOM-4124
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-DMP-Fund-File

@dmp_rcrlbu_boci_funds @tom_4124 @dmp_fund_apps @fund_apps_funds @tom_4489
Feature: TOM-4124: Funds RCRLBU BOCI file load (Golden Source)

  1) Fund creation in DMP through any feed file load from RCRLBU.
  2) As the fund file is dependant on ORG Chart for FINS data, we are loading the dependant ORG Chart data first.

  #Prerequisites
  Scenario: TC_1: Clear ACID data, set variables and load pre-requisite Org Chart data
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Funds" to variable "testdata.path"
    And I assign "BOCIEISLFUNDLE20181218_test.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/BOCI" with reference to "FUND_ID" column and assign to variables:
      | FUND_ID             | ACT_ID    |
      | FUND_VEHICLE_TYPE   | FVT       |
      | PRU_GROUP_LE_ID     | PRU_LE_ID |
      | INV_DIS_LE_ID       | INV_LE_ID |
      | INV_DIS_LE_VR_DISC  | LE_VR     |
      | INV_DIS_LE_INV_DISC | LE_INV    |

    #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"

    #Setting INVLOC according to Data Source
    And I assign "HK" to variable "INVLOC"

    And I execute below query
    """
    ${testdata.path}/sql/ClearACID.sql
    """

  #Load pre-requisite ORG Chart Data before file
    When I copy files below from local folder "${testdata.path}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | BOCI_ORG_Chart_template.xls |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | BOCI_ORG_Chart_template.xls |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL      |
      | BUSINESS_FEED |                             |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_2: File load for RCRLBU Fund for Data Source BOCI

    When I copy files below from local folder "${testdata.path}/inputfiles/BOCI" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      AND TASK_SUCCESS_CNT = 1
      """

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

  #Verification of ACST for MNG Flag for the fund loaded with required data from file
    Then I expect value of column "MNG_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as MNG_COUNT FROM FT_T_ACST
      WHERE END_TMS IS NULL
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND STAT_DEF_ID = 'MNGFLAG'
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