#https://jira.pruconnect.net/browse/EISDEV-6287
#This is feature file tests reload functionality for Security Borrowing and Lending (SBL) Positions
#EISDEV-6371- Changes for picking up positions from FUND Custody account number and change in encoding to UTF-8
#EISDEV-6476: Adding collateral positions
#EISDEV-7123: Duplicate SEDOL end-date script

@gc_interface_securities @gc_interface_portfolios @gc_interface_positions @gc_interface_funds
@dmp_regression_integrationtest
@eisdev_6287_reload @sbl @sbl_robo_reload @dmp_fundapps_regression
@eisdev_6371 @eisdev_6476 @eisdev_7123

Feature: FundApps | SBL Positions | ROBO | Reload Positions

  This feature file tests the re-load functionality for ROBO SBL Positions.
  New Workflow EIS_GenerateSqlFromFileAndExecute_LoadFile will be triggerd with the required parameters.

  The workflow would
  1. Delete all the existing Positions in DMP
  2. Reload New Positions in DMP

  Test File has been created with three records.
  1st and 3rd records are valid, expected to load successfully as the position date is same file date.
  while, 2nd record have incorrect position date, hence it should be filtered.

  We would be loading the normal positions (prerequisite to load SBL positions) and sbl positions for a dynamic date,
  same would be deleted and re-loaded using the new workflow

  Scenario: Pre-requisite Data Delete and Set Variables
  Deleting existing positions for T-2 date

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions" to variable "testdata.path"

    And I assign "BEFORE_ROBONORMALPOSITIONS" to variable "INPUT_FILENAME_BEFORE_NORMAL"
    And I assign "BEFORE_ROBOSBLPOSITIONS" to variable "INPUT_FILENAME_BEFORE_SBL"
    And I assign "AFTER_ROBOSBLPOSITIONS" to variable "INPUT_FILENAME_AFTER_SBL"

    And I assign "/dmp/archive/in/ssdr" to variable "MOVE_DIRECTORY"

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

    And I execute below query to "Delete existing positions for ${DYNAMIC_FILE_DATE}"
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

  Scenario: Load ROBO Normal Position Data
  Loading Normal Positions for T-2 Date

    Given I create input file "${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_FILENAME_BEFORE_NORMAL}.csv" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_POSITION                                 |
      | BUSINESS_FEED |                                                          |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Load Portfolio Custodians
    When I process "${testdata.path}/inputfiles/DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx" file with below parameters
      | FILE_PATTERN  | DMP_R3_PortfolioMasteringTemplate_ROBO.xlsx |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE        |
      | BUSINESS_FEED |                                             |

  Scenario: Load ROBO SBL Position Data
  Loading SBL Positions for T-2 Date
    When I create input file "${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_FILENAME_BEFORE_SBL}.csv" from location "${testdata.path}/inputfiles"
    #When I convert file "${testdata.path}/inputfiles/template/${INPUT_FILENAME_BEFORE_SBL}.csv" encoding format from "UTF-16" to "UTF-8"
    #And I create input file "${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_FILENAME_BEFORE_SBL}_UTF-8.csv" from location "${testdata.path}/inputfiles"
    #And I convert file "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.csv" encoding format from "UTF-8" to "UTF-16"

    And I execute below query to "change RDMSCTYP to COM"
     """
     tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/ROBO_Positions/sql/ISCL_Correction.sql
     """

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.csv" file with below parameters
      | BUSINESS_FEED |                                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION                          |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario: Verify ROBO SBL Positions are loaded
  Verify 3 Record for BALH are available with RQSTR_ID = 'ROBOSBL' AND AS_OF_TMS

    Then I expect value of column "BALH_ROBOSBL_BEFORE" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) AS BALH_ROBOSBL_BEFORE FROM FT_T_BALH
    WHERE RQSTR_ID = 'ROBOSBL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
    """

    Then I expect value of column "BALH_ROBOCOLL_BEFORE" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS BALH_ROBOCOLL_BEFORE FROM FT_T_BALH
    WHERE RQSTR_ID = 'ROBOCOLL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
    """

  Scenario: Execute EIS_GenerateSqlFromFileAndExecute_LoadFile
  Verify Workflow is successfully executed with Success Count 2 and Partial Count 1.

    When I create input file "${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_FILENAME_AFTER_SBL}.csv" from location "${testdata.path}/inputfiles"
#    When I convert file "${testdata.path}/inputfiles/template/${INPUT_FILENAME_AFTER_SBL}.csv" encoding format from "UTF-16" to "UTF-8"
#    And I create input file "${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv" using template "${INPUT_FILENAME_AFTER_SBL}_UTF-8.csv" from location "${testdata.path}/inputfiles"
#    And I convert file "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv" encoding format from "UTF-8" to "UTF-16"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute_LoadFile/request.xmlt" to variable "BICS_RR_WF"
    And I process the workflow template file "${BICS_RR_WF}" with below parameters and wait for the job to be completed
      | EXECUTE_SQL                     | true                                                                         |
      | FILE_URI                        | ${dmp.ssh.inbound.path}/${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGETYPE_GENERATESQLFROMFILE | EIS_MT_ROBO_DMP_SBL_DELETE_POSITION                                          |
      | MESSAGETYPE_STANDARDFILELOAD    | EIS_MT_ROBO_DMP_SBL_POSITION                                                 |
      | OUTPUT_DIRECTORY                | ${MOVE_DIRECTORY}                                                            |
      | SUCCESS_ACTION                  | MOVE                                                                         |

    And I execute below query and extract values of "JOB_ID" into same variables
     """
     SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
     """

  Scenario: Verify File is Moved to the Archive directory
  Verify file is move to archive location

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${MOVE_DIRECTORY}" after processing:
      | ${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv |

  Scenario: Verify Positions Data After Re-load
  Verify only 2 Record for BALH with RQSTR_ID = 'ROBOSBL' AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE}','DD-Mon-YY') are available

    Then I expect value of column "BALH_ROBOSBL_AFTER" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS BALH_ROBOSBL_AFTER FROM FT_T_BALH
    WHERE RQSTR_ID = 'ROBOSBL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
    """

    Then I expect value of column "BALH_ROBOCOLL_AFTER" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS BALH_ROBOCOLL_AFTER FROM FT_T_BALH
    WHERE RQSTR_ID = 'ROBOCOLL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE_SBL}','DD Mon YYYY')
    """

  Scenario: Verify Exception is thrown as part of delete processing for the position date mismatch

    Then I expect value of column "POSITIONDATE_MISMATCH_EXCEPTION_DELETE" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS POSITIONDATE_MISMATCH_EXCEPTION_DELETE FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM FT_T_JBLG
       WHERE PRNT_JOB_ID = '${JOB_ID}'
       AND JOB_MSG_TYP = 'EIS_MT_ROBO_DMP_SBL_DELETE_POSITION')
     )
    AND NOTFCN_STAT_TYP='OPEN'
    AND NOTFCN_ID = '60003'
    AND PARM_VAL_TXT like 'User defined Error thrown! . Can not process record as incoming position date 16 Feb 2020 and prior business dates % are different'
    """
