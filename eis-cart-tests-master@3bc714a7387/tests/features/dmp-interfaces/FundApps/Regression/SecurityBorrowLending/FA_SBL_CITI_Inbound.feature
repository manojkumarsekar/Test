#https://jira.intranet.asia/browse/TOM-5045
#This is inbound file for Security Borrowing and Lending (SBL) coming from CITI
#TOM-5287: Replacing MNG Position scenarios due to MNG Demerger. Initially MNG Positions were being used to setup for the SBL positions, now we are setting it up from EIMK
#EISDEV-5396 : As part of this ticket prior business date check in mdx has been added. changing feature file to append dynamic date to file name
#EISDEV-6447 : This feature file was failing only in regression environment as the underlying security was end-dated by other feature file. loading security data before positions load

@gc_interface_securities @gc_interface_portfolios @gc_interface_positions
@dmp_regression_integrationtest
@tom_5045 @tom_5045 @tom_5287 @sbl @eisdev_5396 @eisdev_6447
Feature: FundApps | CITI | SBL Positions | Inbound feature

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending" to variable "TESTDATA_PATH"
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """
    And I assign "200" to variable "workflow.max.polling.time"

    Given I execute below query
    """
    ${TESTDATA_PATH}/CITI_Positions/sql/Clear_balh.sql
    """

  Scenario: Load Portfolio Template for Custodian setup

    When I copy files below from local folder "${TESTDATA_PATH}/CITI_Positions/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | CITI_SBL.xlsx |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | CITI_SBL.xlsx                        |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: End date Instruments in GC

    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'FR0000120644','US2330518794'"

  Scenario: Load TMBAM Security Data
  Loading Security Data

    Then I copy files below from local folder "${TESTDATA_PATH}/CITI_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | EIMKEISLINSTMT.csv |

    Then I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | EIMKEISLINSTMT.csv       |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_SECURITY |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Load EIMK Position Data

    Given I assign "EIMK-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "EIMK-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/CITI_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/CITI_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | EIMK-POSN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | EIMK-POSN.csv            |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Load CITI SBL Position Data

    Given I execute below query and extract values of "DYNAMIC_FILE_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'YYYYMMDD') as DYNAMIC_FILE_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I assign "CITI-POSN" to variable "INPUT_FILENAME"
    And I assign "CITI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"

    Given I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD-Mon-YY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/CITI_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/CITI_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_CITI_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Verification of BALH table for the positions loaded with required data from file

    Then I expect value of column "BALH_COUNT_ASSPLT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT_ASSPLT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B1Y9TB3'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASSPLT')
         AND    BALH.STRATEGY_ID='1'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

    Then I expect value of column "BALH_COUNT_ASPLIF" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT_ASPLIF
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'BG6N3R2'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASPLIF')
         AND    BALH.STRATEGY_ID='1'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

    Then I expect value of column "BALH_COUNT_ASPLVE" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) as BALH_COUNT_ASPLVE
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'BG6N3R2'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASPLVE')
         AND    BALH.STRATEGY_ID='1'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

  Scenario: Load CITI file again for Strategy ID 2 records

    When I copy files below from local folder "${TESTDATA_PATH}/CITI_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_CITI_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Verifying data load

    Then I expect value of column "BALH_COUNT_ASSPLT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT_ASSPLT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B1Y9TB3'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASSPLT')
         AND    BALH.STRATEGY_ID='2'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

    Then I expect value of column "BALH_COUNT_ASPLIF" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT_ASPLIF
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'BG6N3R2'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASPLIF')
         AND    BALH.STRATEGY_ID='2'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

    Then I expect value of column "BALH_COUNT_ASPLVE" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT_ASPLVE
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'BG6N3R2'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'CITISBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('ASPLVE')
         AND    BALH.STRATEGY_ID='1'
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory