#https://jira.intranet.asia/browse/EISEV-6287
#EISDEV-6476: collateral positions for ROBO
#EISDEV-6995: Exception scenario handling
#EISDEV-7121: Other feature file was deactivated SEDOL : B2NJ7Z1 from BNP and BRS datasource so added one more script(ISID_Correction_B2NJ7Z1_Rollback) to rollback the change which was done by other feature file

@gc_interface_securities @gc_interface_portfolios @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@dmp_fundapps_functional @dmp_fundapps_regression @sbl @sbl_robo_test @eisdev_6476 @eisdev_6995 @eisdev_7121 @eisdev_7570
Feature: FundApps | ROBO | Collateral Positions | Inbound feature

  1. B2NJ7Z1-TEST2: This will fail due to missing EXAC.
  2 and 3. B2NJ7Z1 Collateral positions: Set up 2 collateral positions given sedol.
  4. US36962G3P70 - Collateral position without SEDOL, it should still set up with random listing
  5. No Sedol and ISIN, should throw exception
  6. XS20TSTRC239 - should set up an instrument and create a collateral position with that instrument
  7. 0490656 - should fail due to duplicate SEDOL

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions" to variable "testdata.path"
    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
    """
     select to_char(max(GREG_DTE),'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """
    And I execute below query and extract values of "DYNAMIC_FILE_DATE" into same variables
    """
     select to_char(max(GREG_DTE),'YYYYMMDD') as DYNAMIC_FILE_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

  Scenario: Clear old ROBO Position Data

    Given I execute below query to "Delete existing positions for ${DYNAMIC_FILE_DATE} and set up instrument data for exception"
    """
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/Clear_balh.sql;
    tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/ISIDsetup.sql;
    """

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'B2NJ7Z1'"

  Scenario: Load ROBO Instrument data

    When I process "${testdata.path}/inputfiles/ROBOEISLINSTMT20200505.CSV" file with below parameters
      | FILE_PATTERN  | ROBOEISLINSTMT20200505.CSV |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SECURITY   |
      | BUSINESS_FEED |                            |

    Then I expect workflow is processed in DMP with success record count as "6"

  Scenario: Load ROBO Fund data

    When I process "${testdata.path}/inputfiles/ROBOEISLFUNDLE20200505.CSV" file with below parameters
      | FILE_PATTERN  | ROBOEISLFUNDLE20200505.CSV |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_FUND       |
      | BUSINESS_FEED |                            |

    Then I expect workflow is processed in DMP with total record count as "3"

    And I expect workflow is processed in DMP with fail record count as "0"

  Scenario: Load Portfolio Custodians

    When I process "${testdata.path}/inputfiles/DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx" file with below parameters
      | FILE_PATTERN  | DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE        |
      | BUSINESS_FEED |                                             |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Load ROBO SBL Position Data

    Given I assign "ROBOSBL-POSN_COLL" to variable "INPUT_FILENAME"

    And I assign "ROBOSBL-POSN_COLL_TEMPLATE" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_TEMPLATENAME}.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION               |
      | BUSINESS_FEED |                                            |

    Then I expect workflow is processed in DMP with total record count as "7"
    
    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 60029                                                                                                 |
      | CHAR_VAL_TXT    | The External Account %TEST2 - CUSTDIAN% received from ROBO could not be found in the ExternalAccount. |
      | NOTFCN_STAT_TYP | OPEN                                                                                                  |

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 60001                                                                                                                                           |
      | CHAR_VAL_TXT    | Missing Data Exception:- User defined Error thrown! . Cannot process record as required fields, Sedol, ISIN is not present in the input record. |
      | NOTFCN_STAT_TYP | OPEN                                                                                                                                            |

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 23                                                                                      |
      | CHAR_VAL_TXT    | The Issue for %SEDOL - 0490656% provided by ROBO is not present in the IssueIdentifier. |
      | NOTFCN_STAT_TYP | OPEN                                                                                    |

    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID       | 188                                                                                       |
      | CHAR_VAL_TXT    | Multiple Rows Found for FT_T_ISID having key fields : ID Context=SEDOL, Issue ID=0490656. |
      | NOTFCN_STAT_TYP | OPEN                                                                                      |

  Scenario: Verification of BALH table for the B2NJ7Z1:PR3W multiple Collateral position loaded with for 2 accounts required data from file

    Then I expect value of column "STRATEGY_ID_1_PR3W_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) as STRATEGY_ID_1_PR3W_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('SEDOL')
         AND    ISID.ISS_ID = 'B2NJ7Z1'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOCOLL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
      """

    Then I expect value of column "XS20TSTRC239_PR3W_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) as XS20TSTRC239_PR3W_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('ISIN')
         AND    ISID.ISS_ID = 'XS20TSTRC239'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'ROBOCOLL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('PHKL_European_Multi')
         AND    ADJST_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
         AND    AS_OF_TMS = TO_DATE('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
      """

  Scenario: Removing test data

    Given I execute below query to "Delete existing positions for ${DYNAMIC_FILE_DATE} and set up instrument data for exception"
    """
    delete from ft_t_isid where isid_oid='AB${DYNAMIC_FILE_DATE}'
    """