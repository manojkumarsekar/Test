#https://jira.intranet.asia/browse/TOM-4127
#https://collaborate.intranet.asia/display/FUNDAPPS/SSDR-RCRLBU-POSITION-file

@dmp_rcrlbu_esjp_positions @tom_4127 @dmp_fundapps_functional @fund_apps_positions @tom_4320 @tom_4490
Feature: TOM-4127: Positions RCRLBU ESJP file load (Golden Source)

  1) Positions creation on security and fund combination in DMP through any feed file load from RCRLBU.
  2) As the security and fund data is not set up in the database yet, we are temporarily setting up the required identifiers through inserts. These will be replaced by file load steps once security and fund are completed.

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source ESJP and initial variable assignment

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Positions" to variable "testdata.path"
    And I assign "ESJPEISLPOSITN20181218_test.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/ESJP" with reference to "Position Date" column and assign to variables:
      | Position Date | DATE_P   |
      | Security Id   | ISS_ID   |
      | Fund Id       | ACT_ID   |
      | Quantity      | QUANTITY |

    #Setting ID_CTXT according to Data Source
    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "ESJPCODE" to variable "ISSU_ID_CTXT"
    And I assign "ESJPEOD" to variable "RQSTR_ID"

    And I execute below query
    """
    ${testdata.path}/sql/ClearBALH.sql
    """

    #Instrument and Account that we are setting up identifiers with. This is a temporary step as data is not present
    #And I assign "GS0000001286" to variable "ACCTID"
    #ISIN for instrument to link to
    #And I assign "US02665WCS89" to variable "INSTRID"

    #Instrument and Account identifiers for RCRLBU need to be set up before running position files
    #And I execute below query
    #"""
    #${testdata.path}/sql/InsertIdentifier.sql
    #"""

  Scenario: TC_2: Load pre-requisite ORG Chart Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESJP_ORG_Chart_template.xls |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ESJP_ORG_Chart_template.xls |
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

  Scenario: TC_3: Load pre-requisite Fund Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESJPEISLFUNDLE20181218_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ESJPEISLFUNDLE*      |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_FUND |
      | BUSINESS_FEED |                      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_4: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESJPEISLINSTMT20181218_test.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ESJPEISLINSTMT*          |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_5: File load for RCRLBU Position for Data Source ESJP

    When I copy files below from local folder "${testdata.path}/inputfiles/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_POSITION |
      | BUSINESS_FEED |                          |

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

  Scenario: TC_6: Verification of BALH table for the positions loaded with required data from file

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