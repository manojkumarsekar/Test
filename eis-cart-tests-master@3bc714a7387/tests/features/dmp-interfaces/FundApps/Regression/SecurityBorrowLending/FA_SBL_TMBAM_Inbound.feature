#https://jira.intranet.asia/browse/TOM-5033
#This is inbound file for Security Borrowing and Lending (SBL) coming from TMBAM
#The format of the file is the same as inbound position file received from TMBAM
# and hence used the same mdx with different message type and distinct requestor id
#EISDEV-5396 : As part of this ticket prior business date check in mdx has been added. changing feature file to append dynamic date to file name
#Removing the feature file from regression due to decommissioning of RCR file load for TMBAM

@gc_interface_positions
@dmp_regression_integrationtest @ignore
@tom_5033 @tom_5045 @tom_5095 @dmp_fundapps_functional @dmp_fundapps_regression @tom_5148 @sbl @eisdev_5396 @eisdev_6236
Feature: FundApps | TMBAM | SBL Positions | Inbound feature

  1. TH0646010Z00:E01 Normal position not present in database. - Exception 60027 is thrown and record not loaded
  2. TH0148A10Z06:E01 Normal position present in database but value is less than lend position value. - Exception 60028 is thrown and record not loaded
  3. TH8319010006:E01 Normal position is present in database and value is greater than/equal to lend position value - Record successfully loaded. Very BALH AND BHST
  4. TH0101A10Z01:LF1 2 SBL positions being loaded with same Account-Instrument combination with appropriate normal position in database: Both should be set up in database. First position should have STRATEGY_ID 1 and Second position should have strategy ID 2.

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

  Scenario: Clear old TMBAM Position Data

    Given I execute below query
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/TMBAM_Positions/sql/Clear_balh.sql
    """

  Scenario: Load TMBAM Position Data

    Given I assign "TBAMEISLPOSITN.csv" to variable "INPUT_FILENAME"
    And I assign "TBAMEISLPOSITN_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/TMBAM_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/TMBAM_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_POSITION |
      | BUSINESS_FEED |                           |

    #Verification of successful File load
    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TMBAM SBL Position Data

    Given I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'DD-Mon-YY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    Given I assign "TMBAMSBL-POSN" to variable "INPUT_FILENAME"
    And I assign "TMBAMSBL-POSN_TEMPLATE.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}" from location "${TESTDATA_PATH}/TMBAM_Positions/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH}/TMBAM_Positions/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_SBL_POSITION              |
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

  Scenario: Verification of BALH and BHST table for the TH8319010006:E01 single SBL position loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
        WHERE  BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('TMBAMCDE')
        AND    ISID.ISS_ID IN ('TH8319010006')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'TMBAMSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('E01')
        AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
        AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
        AND    STRATEGY_ID=1
      """

    Then I expect value of column "BHST_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BHST_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID, FT_T_BHST BHST
        WHERE  BALH.BALH_OID = BHST.BALH_OID
        AND    BHST.STAT_DEF_ID = 'CNPFNSBL'
        AND    BHST.DATA_SRC_ID = 'TMBAM'
        AND    BHST.END_TMS IS NULL
        AND    BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('TMBAMCDE')
        AND    ISID.ISS_ID IN ('TH8319010006')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'TMBAMSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('E01')
        AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
        AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
        AND    STRATEGY_ID=1
      """

  Scenario: Verification of BALH table for the BFCCDC1:OBCB multiple SBL position loaded with required data from file

    Then I expect value of column "STRATEGY_ID_1_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('TMBAMCDE')
         AND    ISID.ISS_ID = 'TH0101A10Z01'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'TMBAMSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('LF1')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    STRATEGY_ID=1
      """

    Then I expect value of column "STRATEGY_ID_2_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_2_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('TMBAMCDE')
         AND    ISID.ISS_ID = 'TH0101A10Z01'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'TMBAMSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('LF1')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE}','DD-Mon-YY')
         AND    STRATEGY_ID=2
      """