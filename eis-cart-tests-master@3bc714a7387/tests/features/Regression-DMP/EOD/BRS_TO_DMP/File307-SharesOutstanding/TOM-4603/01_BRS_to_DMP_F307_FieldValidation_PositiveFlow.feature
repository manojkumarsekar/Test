#Current Ticket: https://jira.intranet.asia/browse/TOM-4603
#Parent Ticket: https://jira.intranet.asia/browse/TOM-2027
#Requirement Link: https:https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMR3&title=R3.IN-NSC02-+Shares+Outstanding+%28BRS-DMP%29+File+307#Test-logicalMapping

@gc_interface_shares
@dmp_regression_unittest
@01_tom_4603_brs_dmp_f307_shares
Feature: EOD-Asia-4 | F307 | BRS to DMP EOD Shares Outstanding Extract : Positive Flow

  Below Scenarios are handled as part of this feature:
  1. Validation for mandatory fields post EOD Shares Outstanding Extract load
  2. Validation for other fields as per requirement
  3. Validation for outstanding shares and total market capitalization post re-load with amended

  Scenario: TC_1: Processing the EOD Shares Outstanding test Extract for verification

    Given I assign "tests/test-data/Regression-DMP/EOD/BRS_TO_DMP/File307-SharesOutstanding/TOM-4603" to variable "testdata.path"
    And I generate value with date format "ddMMYY hhmmss" and assign to variable "VAR_CURRDATE"
    And I assign "4603_EOD_SharesOutstanding_Test_Template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "4603_EOD_SharesOutstanding_Test_Extract_${VAR_CURRDATE}.xml" to variable "INPUT_FILENAME_1"

    When I execute below query and extract values of "VAR_NEW_INSERT_SEC" into same variables
    """
    SELECT  ISS_ID AS VAR_NEW_INSERT_SEC FROM FT_T_ISID ISID WHERE ISID.ID_CTXT_TYP = 'BCUSIP' AND ISID.END_TMS IS NULL AND ISID.INSTR_ID NOT IN (SELECT ISMC.INSTR_ID FROM FT_T_ISMC ISMC WHERE ISMC.END_TMS IS NULL)
    AND ROWNUM = 1
    """

    Then  I create input file "${INPUT_FILENAME_1}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | CURRDATE | DateTimeFormat:dd/MM/yyyy   |
      | CUSIP    | ${VAR_NEW_INSERT_SEC}       |
      | RND_NUM  | DateTimeFormat:HHmmSS024.87 |


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
      | CSO        | 2        |
      | JPCSO      | 3        |

  Scenario: TC_3: Loading the Shares Outstanding file

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_SHARES_OUTSTANDING |


  Scenario Outline: TC_4: Verifying if pre-existing records for <DATASOURCE> - record number <IndexNum> are updated in FT_T_ISMC through the test extract load

    Given I expect value of column "PROCESSED_<DATASOURCE>_ROW" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) AS PROCESSED_<DATASOURCE>_ROW FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_<DATASOURCE>}' AND END_TMS IS NULL AND CAPITAL_TYP = '<DATASOURCE>' AND LAST_CHG_TMS > TO_DATE('${VAR_PRE_LOAD_TIME_<DATASOURCE>}','DD/MM/YY HH24:MI:SS')
    """
    Examples:
      | DATASOURCE | IndexNum |
      | AO         | 1        |
      | CSO        | 2        |
      | JPCSO      | 3        |


  Scenario: TC_5: Extract field values of the newly inserted record from BRS Shares Outstanding XML Extract to perform column level validation in FT_T_ISMC

    Given I extract below values from the xml file "${testdata.path}/testdata/${INPUT_FILENAME_1}"  with xpath or tagName at index 0 and assign to variables:
      | CUSIP              | VAR_CUSIP_SO           |
      | SEDOL              | VAR_SEDOL              |
      | ISIN               | VAR_ISIN               |
      | DATA_SOURCE        | VAR_DATA_SOURCE        |
      | TOT_MARKET_CAP     | VAR_TOT_MARKET_CAP     |
      | SHARES_OUTSTANDING | VAR_SHARES_OUTSTANDING |

  Scenario Outline: TC_6: F307 Validation of input field: <ValidationStatus> with respective transformations in DMP

    And I execute below query and extract values of "VAR_INSTR_ID_SO" into same variables
    """
    SELECT INSTR_ID AS VAR_INSTR_ID_SO FROM FT_T_ISID WHERE ID_CTXT_TYP = 'BCUSIP' AND ISS_ID = '${VAR_CUSIP_SO}' AND END_TMS IS NULL
    """

    Then I expect value of column "<ValidationStatus>" in the below SQL query equals to "PASS":
    """
    <SQL>
    """
    Examples: Expecting 'PASS' for each field from BRS Shares Outstanding XML Extract vs GC Database
      | ValidationStatus      | SQL                                                                                                                                                                                                                                                                                                                                |
      | INSTR_ID_CHECK        | SELECT CASE WHEN COUNT(INSTR_ID) = 1 THEN 'PASS' ELSE 'FAIL' END AS INSTR_ID_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${VAR_INSTR_ID_SO}' AND END_TMS IS NULL                                                                                                                                                                        |
      | SEDOL_CHECK           | SELECT CASE WHEN COUNT(ISS_ID) = 1 THEN 'PASS' ELSE 'FAIL' END AS SEDOL_CHECK FROM FT_T_ISID WHERE ID_CTXT_TYP = 'SEDOL' AND ISS_ID = '${VAR_SEDOL}'                                                                                                                                                                               |
      | CAPITAL_TYP_CHECK     | SELECT CASE WHEN COUNT(CAPITAL_TYP) = 1 THEN 'PASS' ELSE 'FAIL' END AS CAPITAL_TYP_CHECK FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_SO}' AND END_TMS IS NULL AND CAPITAL_TYP = '${VAR_DATA_SOURCE}'                                                                                                                           |
      | MKT_CPTLZN_CQTY_CHECK | SELECT CASE WHEN COUNT(MKT_CPTLZN_CQTY) = 1 THEN 'PASS' ELSE 'FAIL' END AS MKT_CPTLZN_CQTY_CHECK FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_SO}' AND END_TMS IS NULL AND CAPITAL_TYP = '${VAR_DATA_SOURCE}' AND MKT_CPTLZN_CQTY = '${VAR_TOT_MARKET_CAP}'                                                                     |
      | CAP_SEC_CQTY_CHECK    | SELECT CASE WHEN COUNT(CAP_SEC_CQTY) = 1 THEN 'PASS' ELSE 'FAIL' END AS CAP_SEC_CQTY_CHECK FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_SO}' AND END_TMS IS NULL AND CAPITAL_TYP = '${VAR_DATA_SOURCE}' AND CAP_SEC_CQTY = '${VAR_SHARES_OUTSTANDING}'                                                                          |
      | START_TMS_CHECK       | SELECT CASE WHEN COUNT(START_TMS) = 1 THEN 'PASS' ELSE 'FAIL' END AS START_TMS_CHECK FROM FT_T_ISMC WHERE INSTR_ID = '${VAR_INSTR_ID_SO}' AND END_TMS IS NULL AND CAPITAL_TYP = '${VAR_DATA_SOURCE}' AND TO_CHAR(TO_DATE(START_TMS,'DD/MM/YY HH24:MI:SS'),'DD/MM/YY') = TO_CHAR(TO_DATE(SYSDATE,'DD/MM/YY HH24:MI:SS'),'DD/MM/YY') |



