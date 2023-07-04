#Current Ticket: https://jira.intranet.asia/browse/TOM-4603
#Parent Ticket: https://jira.intranet.asia/browse/TOM-2027
#Requirement Link: https:https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=R3.IN-NSC02-+Shares+Outstanding+%28BRS-DMP%29+File+307#Test-logicalMapping

@gc_interface_shares
@dmp_regression_unittest
@02_tom_4603_brs_dmp_f307_shares
Feature: EOD-Asia-4 | F307 | BRS to DMP EOD Shares Outstanding Extract : Exception Flow

  Below Scenarios are handled as part of this feature:
  1. Validation of exception validations for Shares Outstanding Extract load

  Scenario: TC_1: Processing the EOD Shares Outstanding test Extract for exception verification

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File307-SharesOutstanding/TOM-4603" to variable "testdata.path"
    And I generate value with date format "ddMMYY hhmmss" and assign to variable "VAR_CURRDATE"
    And I assign "4603_EOD_SharesOutstanding_Exceptions_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "4603_EOD_SharesOutstanding_Exceptions_Extract_${VAR_CURRDATE}.xml" to variable "INPUT_FILENAME_1"


    Then  I create input file "${INPUT_FILENAME_1}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | CURRDATE | DateTimeFormat:dd/MM/yyyy   |
      | RND_NUM  | DateTimeFormat:HHmmSS87.025 |


    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

  Scenario Outline: TC_2: Storing pre-load LAST_CHG_TMS for data source <DATASOURCE> to verify post-load updates in the database

    Given I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}"  with xpath or tagName at index <IndexNum> and assign to variables:
      | CUSIP | VAR_CUSIP_<DATASOURCE> |

    And I execute below query and extract values of "VAR_INSTR_ID_<DATASOURCE>" into same variables
    """
    SELECT INSTR_ID AS VAR_INSTR_ID_<DATASOURCE> FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = '${VAR_CUSIP_<DATASOURCE>}' AND END_TMS IS NULL
    """

    And I execute below query and extract values of "VAR_PRE_LOAD_TIME_<DATASOURCE>" into same variables
    """
    SELECT TO_CHAR(LAST_CHG_TMS,'DD/MM/YY HH12:MI:SS') AS VAR_PRE_LOAD_TIME_<DATASOURCE> FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_<DATASOURCE>}' AND CAPITAL_TYP = '<DATASOURCE>' AND END_TMS IS NULL
    """

    Examples:
      | DATASOURCE | IndexNum |
      | AO         | 1        |
      | SO         | 2        |
      | CSO        | 3        |
      | JPCSO      | 4        |


  Scenario: TC_3: Loading the Shares Outstanding file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_SHARES_OUTSTANDING |

    And I extract new job id from jblg table into a variable "JOB_ID"


  Scenario: TC_4: Verify exceptions are thrown when Shares Outstanding extract is loaded with missing SHARES_OUTSTANDING for SO, CSO, JPO and AO records

    Then I expect value of column "EXCEPTION_MSG_CHECK" in the below SQL query equals to "5":

      """
      SELECT COUNT(*) AS EXCEPTION_MSG_CHECK FROM FT_T_NTEL NTEL
      JOIN FT_T_TRID TRID
      ON NTEL.LAST_CHG_TRN_ID = TRID.TRN_ID
      AND TRID.JOB_ID = '${JOB_ID}'
      AND NTEL.NOTFCN_STAT_TYP = 'OPEN'
      AND NTEL.MSG_SEVERITY_CDE = '30'
      AND NTEL.PARM_VAL_TXT LIKE ('%SHARES OUTSTANDING is not present in the input record.%')
      """

  Scenario Outline: TC_5: Verifying that records for <DATASOURCE> - record number <IndexNum> are updated in FT_T_ISMC through the test extract load since exception severity is 30

    Given I expect value of column "PROCESSED_<DATASOURCE>_ROW" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) AS PROCESSED_<DATASOURCE>_ROW FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_<DATASOURCE>}' AND END_TMS IS NULL AND CAPITAL_TYP = '<DATASOURCE>' AND LAST_CHG_TMS > TO_DATE('${VAR_PRE_LOAD_TIME_<DATASOURCE>}','DD/MM/YY HH24:MI:SS')
    """
    Examples:
      | DATASOURCE | IndexNum |
      | AO         | 1        |
      | SO         | 2        |
      | CSO        | 3        |
      | JPCSO      | 4        |

  Scenario: TC_6: Verifying that record with invalid data source id - record number 5 is not inserted in FT_T_ISMC through the test extract load

    Given I expect value of column "INVALID_DATASOURCE_ROW" in the below SQL query equals to "0":
    """
    SELECT COUNT(1) AS INVALID_DATASOURCE_ROW FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_XYZ}' AND END_TMS IS NULL AND LAST_CHG_TMS > TO_DATE('${VAR_PRE_LOAD_TIME_XYZ}','DD/MM/YY HH24:MI:SS')
    """