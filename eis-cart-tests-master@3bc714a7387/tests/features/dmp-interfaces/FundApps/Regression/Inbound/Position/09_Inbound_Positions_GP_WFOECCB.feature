#https://jira.intranet.asia/browse/EISDEV-5374
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=50475918

@gc_interface_securities @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@dmp_rcrlbu_positions_wfoe @dmp_fundapps_functional @fa_inbound_positions @fa_inbound @dmp_fundapps_regression @fundapps_positions_inbound_gp @eisdev_5374 @eisdev_5374_positions
Feature: This feature is to load positions file coming in GP format from CCB in DMP and verify if it got loaded successfully

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source WFOECCB and initial variable assignment
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Position" to variable "testdata.path"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I assign "esi_sc_positionnonfx_ccb_qdlp_${VAR_SYSDATE}.csv" to variable "INPUT_FILENAME"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "YYYYMMdd" and assign to "CURR_DATE"
    And I create input file "${INPUT_FILENAME}" using template "esi_sc_positionnonfx_ccb_qdlp_template.csv" from location "${testdata.path}"

    When I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "CLIENT_ID" column and assign to variables:
      | CLIENT_ID | ISS_ID   |
      | POS_DATE  | DATE_P   |
      | PORTFOLIO | ACT_ID   |
      | POS_FACE  | QUANTITY |

    #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "WFOECCBCODE" to variable "ISSU_ID_CTXT"
    And I assign "WFOECCBE" to variable "RQSTR_ID"

    And I execute below query to "clear BALH entries for the data getting loaded in the subsequent step"
    """
    ${testdata.path}/sql/ClearBALHGP.sql
    """

    #Instrument and Account that we are setting up identifiers with
    And I assign "GS0000001286" to variable "ACCTID"
    #ISIN for instrument to link to
    And I assign "XS1679515038" to variable "INSTRID"

    #Instrument and Account identifiers for RCRLBU need to be set up before running position files
    And I execute below query to "insert ACID and ISID"
    """
    ${testdata.path}/sql/InsertIdentifier.sql
    """

  Scenario: TC_2: File load for Position for Data Source WFOECCB

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}           |
      | MESSAGE_TYPE  | EIS_MT_WFOECCB_DMP_POSITION |
      | BUSINESS_FEED |                             |

    Then I expect workflow is processed in DMP with success record count as "1"

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

  Scenario: TC_4: Verification of BALH table for the number of positions loaded to dmp from GP inbound position file

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