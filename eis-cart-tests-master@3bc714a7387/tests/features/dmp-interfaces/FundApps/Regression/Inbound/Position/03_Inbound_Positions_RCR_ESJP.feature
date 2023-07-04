#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File#Test-logicalMapping
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4125
#Testing Ticket : https://jira.intranet.asia/browse/TOM-4461

@gc_interface_securities @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@tom_4461 @dmp_rcrlbu_positions_esjp @dmp_fundapps_functional @fa_inbound_positions @fa_inbound @dmp_fundapps_regression
Feature: Positions RCRLBU EastSpring Japan file load (Golden Source)
  Positions creation in DMP through feed file load from Eastspring Japan RCRLBU.

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source ESJP and initial variable assignment

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Position" to variable "testdata.path"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And  I assign "ESJPEISLPOSITN_${VAR_SYSDATE}.csv" to variable "INPUT_FILENAME"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I create input file "${INPUT_FILENAME}" using template "ESJPEISLPOSITN_Template.csv" from location "${testdata.path}"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" with reference to "Position Date" column and assign to variables:
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

  Scenario: TC_2: Load pre-requisite Fund Data before file

    When I copy files below from local folder "${testdata.path}/testdata/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESJPEISLFUNDLE20190322.csv |

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

  Scenario: TC_3: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/testdata/ESJP" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ESJPEISLINSTMT20190322.csv |

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

  Scenario: TC_4: File load for RCRLBU Position for Data Source ESJP

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When  I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ESJP_DMP_POSITION |
      | BUSINESS_FEED |                          |

    #Verification of successful File load
    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      AND TASK_SUCCESS_CNT = 1
      """

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

