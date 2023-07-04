#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket : https://jira.intranet.asia/browse/TOM-4461
#https://jira.intranet.asia/browse/EISDEV-5400 - Changes to load GP files directly. The Positions connector will load RCR as well GP files in DMP
#https://jira.intranet.asia/browse/EISDEV-5399 - GSDMFiltering where CLIENT_SEC_TYPE is null

@gc_interface_securities @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@tom_4461 @dmp_rcrlbu_positions_wfoe @dmp_fundapps_functional @fa_inbound_positions @fa_inbound @dmp_fundapps_regression
@eisdev_5400 @fundapps_positions_inbound_gp @eisdev_5539

Feature: Positions GP WFOE file load (Golden Source)

  1) Positions creation on security and fund combination in DMP through any feed file load from RCRLBU.
  2) As the security and fund data is not set up in the database yet, we are temporarily setting up the required identifiers through inserts. These will be replaced by file load steps once security and fund are completed.

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source WFOE and initial variable assignment
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Position" to variable "testdata.path"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And  I assign "WFOEEISLPOSITN_${VAR_SYSDATE}.csv" to variable "INPUT_FILENAME"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "YYYYMMdd" and assign to "CURR_DATE"
    And I create input file "${INPUT_FILENAME}" using template "WFOEEISLPOSITN_Template.csv" from location "${testdata.path}"

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | ISS_ID   |
      | POS_DATE  | DATE_P   |
      | PORTFOLIO | ACT_ID   |
      | POS_FACE  | QUANTITY |

    #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "WFOECODE" to variable "ISSU_ID_CTXT"
    And I assign "WFOEEOD" to variable "RQSTR_ID"

    And I execute below query
    """
    ${testdata.path}/sql/ClearBALHGP.sql
    """

    #Instrument and Account that we are setting up identifiers with. This is a temporary step as data is not present
    And I assign "GS0000001286" to variable "ACCTID"
    #ISIN for instrument to link to
    And I assign "XS1679515038" to variable "INSTRID"

    #Instrument and Account identifiers for RCRLBU need to be set up before running position files
    And I execute below query
    """
    ${testdata.path}/sql/InsertIdentifier.sql
    """

  Scenario: TC_2: File load for RCRLBU Position for Data Source WFOE

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_WFOE_DMP_POSITION |
      | BUSINESS_FEED |                          |

    #Verification of successful File load
    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 2
      AND TASK_CMPLTD_CNT = 2
      AND TASK_SUCCESS_CNT = 1
      AND TASK_FILTERED_CNT = 1
      """

  Scenario: TC_3: Verification of BALH table for the positions loaded with required data from file

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
         AND    ADJST_TMS = TO_DATE('${DATE_P}','YYYYMMDD')
         AND    AS_OF_TMS = TO_DATE('${DATE_P}','YYYYMMDD')
      """

  Scenario: TC_4: Verification of BALH table for the number of positions loaded to dmp from RCR inbound position file

    Then I expect value of column "POSITIONS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS POSITIONS_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP='${ISSU_ID_CTXT}'
         AND    ISID.ISS_ID = ('${ISS_ID}')
         AND    ISID.END_TMS IS NULL
         AND    ISID.ISS_ID IS NOT NULL
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ALT_ID='${ACT_ID}'
         AND    BALH.RQSTR_ID = '${RQSTR_ID}'
         AND    ACID.ACCT_ID_CTXT_TYP ='${ACCT_ID_CTXT}'
         AND    ACID.END_TMS IS NULL
         AND    ADJST_TMS = TO_DATE('${DATE_P}','YYYYMMDD')
         AND    AS_OF_TMS = TO_DATE('${DATE_P}','YYYYMMDD')
      """