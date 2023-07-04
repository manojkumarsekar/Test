#https://collaborate.pruconnect.net/display/EISTOMR4/FA-IN-SMF-LBURCR-DMP-Security-File
#https://jira.pruconnect.net/browse/EISDEV-6128

@gc_interface_securities @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@eisdev_6128 @dmp_rcrlbu_positions_robo @dmp_fundapps_functional @fa_inbound_positions @fa_inbound @dmp_fundapps_regression @eisdev_6128_positions
Feature: Positions RCRLBU ROBO file load (Golden Source)

  Verifying Positions creation in DMP through feed file load from ROBO RCRLBU and if the required attributes have been set up.

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source ROBO and initial variable assignment

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Position" to variable "testdata.path"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I assign "ROBOEISLPOSITN_${VAR_SYSDATE}.csv" to variable "INPUT_FILENAME"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I create input file "${INPUT_FILENAME}" using template "ROBOEISLPOSITN_Template.csv" from location "${testdata.path}"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Position Date" column and assign to variables:
      | Position Date | DATE_P   |
      | Security Id   | ISS_ID   |
      | Fund Id       | ACT_ID   |
      | Quantity      | QUANTITY |
     #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "ROBOCODE" to variable "ISSU_ID_CTXT"
    And I assign "ROBOEOD" to variable "RQSTR_ID"
    And I execute below query to "remove the Positions related ROBO source"
      """
      ${testdata.path}/sql/ClearBALH.sql
      """

  Scenario: TC_2: Load pre-requisite Fund Data before file

    Given I assign "ROBOEISLFUNDLE20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/ROBO/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ROBOEISLFUNDLE*      |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_FUND |
      | BUSINESS_FEED |                      |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_3: Load pre-requisite Security Data before file

    Given I assign "ROBOEISLINSTMT20200421.CSV" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/ROBO/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ROBOEISLINSTMT*          |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_4: File load for RCRLBU Position for Data Source ROBO

    Given I assign "ROBOEISLPOSITN_${VAR_SYSDATE}.csv" to variable "INPUT_FILENAME"

    When I process "${testdata.path}/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_POSITION |
      | BUSINESS_FEED |                          |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC_5: Verification of BALH table for the positions loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('${ISSU_ID_CTXT}')
         AND    ISID.ISS_ID IN ('${ISS_ID}')
         AND    ISID.END_TMS IS NULL
         AND    ISID.ISS_ID IS NOT NULL
         AND    BALH.RQSTR_ID = '${RQSTR_ID}'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('${ACCT_ID_CTXT}')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('${ACT_ID}')
         AND    QTY_CQTY='${QUANTITY}'
         AND    ADJST_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
         AND    AS_OF_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
      """

  Scenario: TC_6: Verification of BALH table for the number of positions loaded to dmp from RCR inbound position file

    Then I expect value of column "POSITIONS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS POSITIONS_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP='${ISSU_ID_CTXT}'
         AND    ISID.END_TMS IS NULL
         AND    ISID.ISS_ID IS NOT NULL
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    BALH.RQSTR_ID = '${RQSTR_ID}'
         AND    ACID.ACCT_ALT_ID='${ACT_ID}'
         AND    ACID.ACCT_ID_CTXT_TYP ='${ACCT_ID_CTXT}'
         AND    ACID.END_TMS IS NULL
         AND    ADJST_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
         AND    AS_OF_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
      """