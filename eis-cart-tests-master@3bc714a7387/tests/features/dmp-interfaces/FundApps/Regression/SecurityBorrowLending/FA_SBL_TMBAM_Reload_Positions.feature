#https://jira.pruconnect.net/browse/EISDEV-5396
#This is feature file tests reload functionality for Security Borrowing and Lending (SBL) Positions
#EISDEV-6447 : This feature file was failing only in regression environment as the underlying security was end-dated by other feature file. loading security data before positions load
#Removing the feature file from regression suite since this is not required after TH Go Live

@gc_interface_positions @gc_interface_securities @ignore
@dmp_regression_integrationtest
@eisdev_5396 @sbl @sbl_tmbam_reload @dmp_fundapps_regression @eisdev_6447
Feature: FundApps | SBL Positions | TMBAM | Reload Positions

  This feature file tests the re-load functionality for TMBAM SBL Positions.
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
  Deleting existing positions for T date

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/SecurityBorrowLending/TMBAM_Positions" to variable "testdata.path"

    And I assign "BEFORE_TBAMNORMALPOSITIONS" to variable "INPUT_FILENAME_BEFORE_NORMAL"
    And I assign "BEFORE_TBAMSBLPOSITIONS" to variable "INPUT_FILENAME_BEFORE_SBL"
    And I assign "AFTER_TBAMSBLPOSITIONS" to variable "INPUT_FILENAME_AFTER_SBL"

    And I assign "/dmp/archive/in/brs" to variable "MOVE_DIRECTORY"

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
    """
    select to_char(max(GREG_DTE),'DD/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp
    where cal_id = 'PRPTUAL'
    and GREG_DTE < trunc(sysdate)
    and BUS_DTE_IND = 'Y'
    and END_TMS IS NULL
    """

    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "dd/MM/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"

    And I execute below query to "Delete existing positions for ${DYNAMIC_FILE_DATE}"
    """
    DELETE FT_T_BHST WHERE BALH_OID IN (SELECT BALH_OID FROM FT_T_BALH WHERE RQSTR_ID LIKE '%BRSEOD%' AND AS_OF_TMS = TO_DATE ('${DYNAMIC_FILE_DATE}','YYYYMMDD'));
    DELETE FT_T_BALH WHERE RQSTR_ID LIKE '%BRSEOD%' AND AS_OF_TMS = TO_DATE ('${DYNAMIC_FILE_DATE}','YYYYMMDD');
    COMMIT
    """

  Scenario: Load TMBAM Security Data
  Loading Security Data

    When I process "${testdata.path}/inputfiles/testdata/SEC_TMBAM_SM.xml" file with below parameters
      | FILE_PATTERN  | SEC_TMBAM_SM.xml        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario: Load TMBAM Normal Position Data
  Loading Normal Positions for T Date

    Given I create input file "${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_FILENAME_BEFORE_NORMAL}.xml" from location "${testdata.path}/inputfiles"

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.csv |

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
      | FILE_PATTERN        | ${INPUT_FILENAME_BEFORE_NORMAL}_${DYNAMIC_FILE_DATE}.xml |
      | MESSAGE_TYPE        | EIS_MT_BRS_EOD_POSITION_NON_LATAM                        |
      | BUSINESS_FEED       |                                                          |
      | NOOFFILESINPARALLEL | 1                                                        |

    Then I expect workflow is processed in DMP with success record count as "5"

  Scenario: Load TMBAM SBL Position Data
  Loading SBL Positions for T Date

    Given I create input file "${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_FILENAME_BEFORE_SBL}.xml" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.xml" file with below parameters
      | BUSINESS_FEED |                                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_BEFORE_SBL}_${DYNAMIC_FILE_DATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211              |

    Then I expect workflow is processed in DMP with success record count as "5"

  Scenario: Verify TMBAM SBL Positions are loaded
  Verify 5 Record for BALH are available with RQSTR_ID = 'TMBAMSBL' AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE}','DD-Mon-YY')

    Then I expect value of column "BALH_TMBAMSBL_BEFORE" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS BALH_TMBAMSBL_BEFORE FROM FT_T_BALH
    WHERE RQSTR_ID = 'BRSTMSBL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE}','DD-Mon-YY')
    """

  Scenario: Execute EIS_GenerateSqlFromFileAndExecute_LoadFile
  Verify Workflow is successfully executed with Success Count 2 and Partial Count 1.

    And I create input file "${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_FILENAME_AFTER_SBL}.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.csv |

    And I set the workflow template parameter "EXECUTE_SQL" to "true"
    And I set the workflow template parameter "FILE_URI" to "${dmp.ssh.inbound.path}/${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.xml"
    And I set the workflow template parameter "MESSAGETYPE_GENERATESQLFROMFILE" to "EIS_MT_TMBAM_DMP_SBL_DELETE_POSITION"
    And I set the workflow template parameter "MESSAGETYPE_STANDARDFILELOAD" to "EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211"
    And I set the workflow template parameter "OUTPUT_DIRECTORY" to "${MOVE_DIRECTORY}"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"

    Then I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute_LoadFile/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_GenerateSqlFromFileAndExecute_LoadFile/flowResultIdQuery.xpath" to variable "flowResultId"

    And I pause for 5 seconds

    And I execute below query and extract values of "JOB_ID" into same variables
     """
     SELECT JOB_ID FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
     """

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "CLOSED":
     """
     SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID}'
     """

  Scenario: Verify File is Moved to the Archive directory
  Verify file is move to archive location

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${MOVE_DIRECTORY}" after processing:
      | ${INPUT_FILENAME_AFTER_SBL}_${DYNAMIC_FILE_DATE}.xml |

  Scenario: Verify Positions Data After Re-load
  Verify only 2 Record for BALH with RQSTR_ID = 'BRSTMSBL' AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE}','DD-Mon-YY') are available

    Then I expect value of column "BALH_TMBAMSBL_AFTER" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS BALH_TMBAMSBL_AFTER FROM FT_T_BALH
    WHERE RQSTR_ID = 'BRSTMSBL'
    AND AS_OF_TMS = TO_DATE ('${DYNAMIC_DATE}','DD-Mon-YY')
    """

  Scenario: Verify Exception is thrown as part of delete processing for the position date mismatch

    Then I expect value of column "POSITIONDATE_MISMATCH_EXCEPTION_DELETE" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS POSITIONDATE_MISMATCH_EXCEPTION_DELETE FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM FT_T_JBLG
       WHERE PRNT_JOB_ID = '${JOB_ID}'
       AND JOB_MSG_TYP = 'EIS_MT_TMBAM_DMP_SBL_DELETE_POSITION')
     AND RECORD_SEQ_NUM = '2')
    AND NOTFCN_ID = '60003'
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND PARM_VAL_TXT like 'User defined Error thrown! . Can not process record as incoming position date 16-Feb-20 and prior business dates % are different'
    """

  Scenario: Verify Exception is thrown as part of file load for the position date mismatch

    Then I expect value of column "POSITIONDATE_MISMATCH_EXCEPTION_LOAD" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS POSITIONDATE_MISMATCH_EXCEPTION_LOAD FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID IN
      (SELECT JOB_ID FROM FT_T_JBLG
       WHERE PRNT_JOB_ID = '${JOB_ID}'
       AND JOB_MSG_TYP = 'EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211')
     AND RECORD_SEQ_NUM = '2')
    AND NOTFCN_ID = '60003'
    AND NOTFCN_STAT_TYP = 'OPEN'
    AND PARM_VAL_TXT like 'User defined Error thrown! . Can not process record as incoming position date 16-Feb-20 and prior business dates % are different'
    """