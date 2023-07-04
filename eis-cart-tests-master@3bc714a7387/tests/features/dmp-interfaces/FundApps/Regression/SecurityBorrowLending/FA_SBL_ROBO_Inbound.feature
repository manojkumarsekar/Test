#https://jira.intranet.asia/browse/EISEV-6287
#This is inbound file for Security Borrowing and Lending (SBL) coming from ROBO
#EISDEV-6371- Changes for picking up positions from FUND Custody account number and change in encoding to UTF-8
#EISDEV-6476: Removing collateral positions scenarios
#EISDEV-7122: Duplicate SEDOL end-date script

@gc_interface_securities @gc_interface_portfolios @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@dmp_fundapps_functional @dmp_fundapps_regression @sbl @eisdev_6287 @sbl_robo_test
@eisdev_6371 @eisdev_6476 @eisdev_7122
Feature: FundApps | ROBO | SBL Positions | Inbound feature

  1. B66P7D2 Normal position not present in database. - Exception 60027 is thrown and record not loaded
  2. B94GK17 Normal position present in database but value is less than lend position value. - Exception 60028 is thrown and record not loaded
  3. B3VJFD4 Normal position is present in database and value is greater than/equal to lend position value - Record successfully loaded. Very BALH AND BHST
  4 and 8. B2NJ7Z1 2 SBL positions being loaded with same Custodian-Instrument combination with appropriate normal position in database: Both should be set up in database. First position should have STRATEGY_ID 1 and Second position should have strategy ID 2.
  5 and 6. B2NJ7Z1-TESTABC and TESTDEF (TESTEXAC Custody account number) :
  two SBL positions being loaded with same Custodian-Instrument combination with appropriate normal position in database: 1 Position should be set up for each account
  7. Sedol not present, hence this will fail.

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions" to variable "testdata.path"
    And I execute below query and extract values of "DYNAMIC_DATE_POS" into same variables
     """
     select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE_POS from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """
    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
     """
     select to_char(max(GREG_DTE),'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """
    And I execute below query and extract values of "DYNAMIC_FILE_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'YYYYMMDD') as DYNAMIC_FILE_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

  Scenario: Clear old ROBO Position Data & Correct ISID entry
    Given I execute below query to "Delete existing positions for ${DYNAMIC_FILE_DATE}"
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/Clear_balh.sql
    """

    And I execute below query to "correct ISID entry for duplicate SEDOL"
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/ISID_Correction.sql
    """

  Scenario: Load ROBO Instrument data

    When I process "${testdata.path}/inputfiles/ROBOEISLINSTMT20200505.CSV" file with below parameters
      | FILE_PATTERN  | ROBOEISLINSTMT20200505.CSV |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SECURITY   |
      | BUSINESS_FEED |                            |

  Scenario: Load ROBO Fund data

    When I process "${testdata.path}/inputfiles/ROBOEISLFUNDLE20200505.CSV" file with below parameters
      | FILE_PATTERN  | ROBOEISLFUNDLE20200505.CSV |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_FUND       |
      | BUSINESS_FEED |                            |

  Scenario: Load ROBO Position Data

    Given I assign "ROBOEISLPOSITN.csv" to variable "INPUT_FILENAME"
    And I assign "ROBOEISLPOSITN_Template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_POSITION |
      | BUSINESS_FEED |                          |

    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario: Load Portfolio Custodians
    When I process "${testdata.path}/inputfiles/DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx" file with below parameters
      | FILE_PATTERN  | DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE        |
      | BUSINESS_FEED |                                             |

  Scenario: Load ROBO SBL Position Data

    Given I assign "ROBOSBL-POSN" to variable "INPUT_FILENAME"

    And I assign "ROBOSBL-POSN_TEMPLATE" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}.csv" from location "${testdata.path}/inputfiles"
    #Commenting out the conversion of file format steps as the file format is now UTF-8, however keeping the steps for reference
    #And I convert file "${testdata.path}/inputfiles/template/${INPUT_TEMPLATENAME}.csv" encoding format from "UTF-16" to "UTF-8"
    #And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}_UTF-8.csv" from location "${testdata.path}/inputfiles"
    #And I convert file "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" encoding format from "UTF-8" to "UTF-16"

    And I execute below query to "change RDMSCTYP to COM"
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/ISCL_Correction.sql
    """

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    #Verification of successful File load
    Then I expect workflow is processed in DMP with total record count as "7"
    And success record count as "4"

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 60027                                                             |
      | CHAR_VAL_TXT    | %Normal position is not set up in the database for lend position% |
      | NOTFCN_STAT_TYP | OPEN                                                              |

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 60028                                                              |
      | CHAR_VAL_TXT    | %Normal position % in the database is less than the lend position% |
      | NOTFCN_STAT_TYP | OPEN                                                               |

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 60001                                                                                                                                     |
      | CHAR_VAL_TXT    | Missing Data Exception:- User defined Error thrown! . Cannot process record as required fields, Sedol is not present in the input record. |
      | NOTFCN_STAT_TYP | OPEN                                                                                                                                      |

  Scenario: Verification of BALH and BHST table for the B3VJFD4 single SBL position loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
        WHERE  BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('SEDOL')
        AND    ISID.ISS_ID IN ('B3VJFD4')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'ROBOSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
        AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
        AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
        AND    STRATEGY_ID=1
      """

    Then I expect value of column "BHST_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BHST_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID, FT_T_BHST BHST
        WHERE  BALH.BALH_OID = BHST.BALH_OID
        AND    BHST.STAT_DEF_ID = 'CNPFNSBL'
        AND    BHST.DATA_SRC_ID = 'ROBO'
        AND    BHST.END_TMS IS NULL
        AND    BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('SEDOL')
        AND    ISID.ISS_ID IN ('B3VJFD4')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'ROBOSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
        AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
        AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
        AND    STRATEGY_ID=1
      """

  Scenario: Verification of BALH table for the B2NJ7Z1:PHKL_European_Multi multiple SBL position loaded with required data from file

    Then I expect value of column "STRATEGY_ID_1_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B2NJ7Z1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    STRATEGY_ID=1
      """

    Then I expect value of column "STRATEGY_ID_2_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_2_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B2NJ7Z1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    STRATEGY_ID=2
      """

  Scenario: Verification of BALH table for the B2NJ7Z1:TESTEXAC multiple SBL position loaded with for 2 accounts required data from file

    Then I expect value of column "STRATEGY_ID_1_TESTABC_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_TESTABC_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B2NJ7Z1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('TESTABC')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    STRATEGY_ID=1
      """

    Then I expect value of column "STRATEGY_ID_1_TESTDEF_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_TESTDEF_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B2NJ7Z1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('TESTDEF')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    STRATEGY_ID=1
      """
