#https://jira.intranet.asia/browse/TOM-5026
#This is inbound file for Security Borrowing and Lending (SBL) coming from MNG
#The format of the file is the same as inbound position file received from MNG and hence used the same mdx with different message type and distinct requestor id
#EISDEV-5396 : As part of this ticket prior business date check in mdx has been added. changing feature file to append dynamic date to file name

@gc_interface_positions
@dmp_regression_integrationtest
@tom_5026 @tom_5045_MNG @tom_5045 @tom_5095 @dmp_fundapps_functional @dmp_fundapps_regression @tom_5148 @eisdev_5396 @sbl
Feature: FundApps | MNG | SBL Positions | Inbound feature

  1. 0408284:SALE Normal position not present in database. - Exception 60027 is thrown and record not loaded
  2. B2Q14Z3:PACEQ Normal position present in database but value is less than lend position value. - Exception 60028 is thrown and record not loaded
  3. BLLHKZ1:PACEQ Normal position is present in database and value is greater than/equal to lend position value - Record successfully loaded.
  4. 6420538:E61101 2 SBL positions being loaded with same Account-Instrument combination with appropriate normal position in database: Both should be set up in database. First position should have STRATEGY_ID 1 and Second position should have strategy ID 2.

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending" to variable "TESTDATA_PATH"
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """
    And I execute below query and extract values of "DYNAMIC_FILE_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'YYYYMMDD') as DYNAMIC_FILE_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

  Scenario: Load MNG Position Data

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/MNG_Positions/sql/Clear_balh.sql
    """

    Given I assign "BOCI-POSN.csv" to variable "INPUT_FILENAME"
    And I assign "BOCI-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/MNG_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/MNG_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BOCI_DMP_POSITION |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load MNG SBL Position Data

    Given I assign "MNGSBL-POSN" to variable "INPUT_FILENAME"
    And I assign "MNGSBL-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/MNG_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/MNG_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SBL_POSITION                |
      | BUSINESS_FEED |                                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Verification of failures due to missing positions and invalid position

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60027'
      AND ntel.CHAR_VAL_TXT LIKE '%Normal position is not set up in the database for lend position%'
      """

    Then I expect value of column "EXCEPTION_MSG2_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG2_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60028'
      AND ntel.CHAR_VAL_TXT LIKE '%Normal position % in the database is less than the lend position%'
      """

  Scenario: Verification of BALH table for the 0540528:OBE single SBL position loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('MNGCODE')
         AND    ISID.ISS_ID = 'BLLHKZ1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'MNGSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('PACEQ')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    STRATEGY_ID=1
      """

  Scenario: Verification of BALH table for the BFCCDC1:OBCB multiple SBL position loaded with required data from file

    Then I expect value of column "STRATEGY_ID_1_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('MNGCODE')
         AND    ISID.ISS_ID = '6420538'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'MNGSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('E61101')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    STRATEGY_ID=1
      """

    Then I expect value of column "STRATEGY_ID_2_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_2_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('MNGCODE')
         AND    ISID.ISS_ID = '6420538'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'MNGSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('E61101')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD/MM/YYYY')
         AND    STRATEGY_ID=2
      """