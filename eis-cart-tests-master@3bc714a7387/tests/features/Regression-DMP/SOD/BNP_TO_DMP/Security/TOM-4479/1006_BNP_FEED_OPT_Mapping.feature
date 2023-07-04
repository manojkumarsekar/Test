#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1006_tom_4479_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Options

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Options Security Feed
  2. Validating Options specific fields mapping for FT_T_ISID, FT_T_FFRL and FT_T_OPCH tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"
    And I assign "ESISODP_SEC_OPT_LOAD.out" to variable "INPUT_FILENAME"

  Scenario Outline: Clear existing data for the row <RowNum> in the input file

    Given I extract below values for row <RowNum> from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | CUSIP               | VAR_CUSIP               |
      | HIP_EXT2_ID         | VAR_HIP_EXT2_ID         |
      | BLOOMBERG_GLOBAL_ID | VAR_BLOOMBERG_GLOBAL_ID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}','${VAR_CUSIP}','${VAR_HIP_EXT2_ID}','${VAR_BLOOMBERG_GLOBAL_ID}'"

    Examples:
      | RowNum |
      | 2      |
      | 3      |

  Scenario: Load Security File for Options

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

  Scenario Outline: BNP Security (Options) Feed Validations for <Column>

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID                 | VAR_INSTR_ID                 |
      | HIP_EXT2_ID              | VAR_HIP_EXT2_ID              |
      | BLOOMBERG_GLOBAL_ID      | VAR_BLOOMBERG_GLOBAL_ID      |
      | INSTR_TYPE               | VAR_INSTR_TYPE               |
      | PUT_CALL_IND             | VAR_PUT_CALL_IND             |
      | STRIKE_PRICE_L           | VAR_STRIKE_PRICE_L           |
      | CCP_CLEARING_MEMBER_CODE | VAR_CCP_CLEARING_MEMBER_CODE |
      | PRIMARY_EXCHANGE         | VAR_PRIMARY_EXCHANGE         |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

    #IssueIdentifier table
    Examples: FT_T_ISID Table Verifications
      | Column            | Query                                                                                                                                                                                                                                                                                 |
      | HIP_EXT2_ID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS HIP_EXT2_ID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'HIPEXT2ID'                                                                                                                       |
      | MKT_OID_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MKT_OID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP IN ('BNP_BBGLOBAL') AND MKT_OID IN (SELECT MKT_OID FROM FT_T_MKID WHERE MKT_ID = '${VAR_PRIMARY_EXCHANGE}' AND MKT_ID_CTXT_TYP = 'MIC') |


#   #The OPCH table is not getting updated -- OptionsCharacteristics table - the option securities are inserted to this table only if the INSTR_TYPE has 2nd char = 'O' and 4th char = 'C'. No such records are currently available.
#    Examples: FT_T_OPCH Table Verifications
#      | Column             | Query                                                                                                                                                                         |
#      | EXER_TYP_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS EXER_TYP_CHECK FROM FT_T_OPCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND EXER_TYP = SUBSTR('${VAR_INSTR_TYPE}',4,1) |
#      | CALL_PUT_TYP_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CALL_PUT_TYP_CHECK FROM FT_T_OPCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CALL_PUT_TYP = '${VAR_PUT_CALL_IND}'   |
#      | STRKE_CPRC_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS STRKE_CPRC_CHECK FROM FT_T_OPCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND STRKE_CPRC = '${VAR_STRIKE_PRICE_L}'     |


#    #FinsRoleIssueParticipant table -- To confirm that the CCP MEMBER CODE in the incoming file is valid
#    Examples: FT_T_FINS Table Verifications
#      | Column                  | Query                                                                                                                                                    |
#      | INST_NME_CCP_MMBR_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INST_NME_CCP_MMBR_CHECK FROM FT_T_FINS WHERE INST_NME = '${VAR_CCP_CLEARING_MEMBER_CODE}' ) |
#
#    #FinancialInstitutionIdentifier table
#    Examples: FT_T_FIID Table Verifications
#      | Column                 | Query                                                                                                                                                  |
#      | FINS_ID_CCP_MMBR_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FINS_ID_CCP_MMBR_CHECK FROM FT_T_FIID WHERE FINS_ID = '${VAR_CCP_CLEARING_MEMBER_CODE}' ) |
#
#    #FinsFinsRole table
#    Examples: FT_T_FFRL Table Verifications
#      | Column                   | Query                                                                                                                                                                                                                                                |
#      | INST_MNEM_CCP_MMBR_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INST_MNEM_CCP_MMBR_CHECK FROM FT_T_FFRL WHERE INST_MNEM IN (SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID_CTXT_TYP = 'CCPCLRMEMBRCDE' AND FINS_ID = '${VAR_CCP_CLEARING_MEMBER_CODE}' ) |