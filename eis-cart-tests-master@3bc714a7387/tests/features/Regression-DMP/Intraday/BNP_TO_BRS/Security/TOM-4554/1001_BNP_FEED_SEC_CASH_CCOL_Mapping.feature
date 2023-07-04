#Ticket link : https://jira.intranet.asia/browse/TOM-4554
#Parent Ticket: https://jira.intranet.asia/browse/TOM-3532
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping

@gc_interface_securities
@dmp_regression_unittest
@1001_tom_4554_bnp_dmp_security
Feature: BNP to DMP Security feed - Field Mapping - Cash Collateral

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Intraday Cash Collateral Security Feed
  2. Validating Cash Collateral specific field mappings for Security tables as per Specifications

  Note: These feature files cover the cash securities that are coming up in Intraday BNP feed. The general validations and exception handling for securities are common and are covered in the SOD feature files.

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/Intraday/BNP_TO_BRS/Security/TOM-4554" to variable "testdata.path"
    And I assign "ESIINTRADAY_SEC_CCOL_LOAD.out" to variable "INPUT_FILENAME"

  Scenario: Clear existing data for the row 2 in the input file

    Given I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | SOURCE_ID           | VAR_SOURCE_ID           |
      | INSTR_LONG_NAME     | VAR_INSTR_LONG_NAME     |
      | INSTR_SHORT_NAME    | VAR_INSTR_SHORT_NAME    |
      | INSTR_TYPE          | VAR_INSTR_TYPE          |
      | ISSUE_CCY           | VAR_ISSUE_CCY           |
      | COUNTRY_OF_RISK     | VAR_COUNTRY_OF_RISK     |
      | GL_TYPE             | VAR_GL_TYPE             |
      | CATEGORY            | VAR_CATEGORY            |
      | SUB_CATEGORY        | VAR_SUB_CATEGORY        |
      | DWH_LAST_UPD_TMS    | VAR_DWH_LAST_UPD_TMS    |
      | DWH_EXTRACT_BATCHID | VAR_DWH_EXTRACT_BATCHID |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_HIP_SECURITY_CODE}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_HIP_SECURITY_CODE}'"

  Scenario: Load Security File

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    Then I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

  Scenario Outline: BNP Security (Cash Collateral) Feed Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """
 #Issue table -- Security master table
    Examples: FT_T_ISSU Table Verifications
      | Column               | Query                                                                                                                                                                             |
      | PREF_ISS_DESC_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PREF_ISS_DESC_CHECK FROM  FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PREF_ISS_DESC = '${VAR_INSTR_LONG_NAME}' |
      | PREF_ISS_NME_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PREF_ISS_NME_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PREF_ISS_NME = '${VAR_INSTR_SHORT_NAME}'   |
      | ISS_TYPE_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_TYPE_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}'                                                    |
      | DENOM_CURR_CDE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS DENOM_CURR_CDE_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND DENOM_CURR_CDE = '${VAR_ISSUE_CCY}'      |

 #IssueIdentifier table
    Examples: FT_T_ISID Table Verifications
      | Column          | Query                                                                                                                                                         |
      | BNPLSTID_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BNPLSTID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'BNPLSTID'   |
      | HIPSECCDE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS HIPSECCDE_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'HIPSECCDE' |


 #IssueDescription table
    Examples: FT_T_ISDE Table Verifications
      | Column         | Query                                                                                                                                                                  |
      | ISS_DESC_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_DESC_CHECK FROM FT_T_ISDE WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_DESC = '${VAR_INSTR_LONG_NAME}' |
      | ISS_NME_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_NME_CHECK FROM FT_T_ISDE WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_NME = '${VAR_INSTR_SHORT_NAME}'  |

 #IssueStatistic table
    Examples: FT_T_ISST Table Verifications
      | Column                  | Query                                                                                                                                                                                                          |
      | STAT_CHAR_VAL_TXT_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS STAT_CHAR_VAL_TXT_CHECK FROM FT_T_ISST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND STAT_DEF_ID = 'SORCEID' AND STAT_CHAR_VAL_TXT = '${VAR_SOURCE_ID}' |

 #IndustryClassification table
    Examples: FT_T_INCL Table Verifications
      | Column             | Query                                                                                                                                                                                                                           |
      | GL_TYPE_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GL_TYPE_CHECK  FROM FT_T_INCL WHERE CL_NME = '${VAR_GL_TYPE}' AND CL_VALUE = '${VAR_GL_TYPE}' AND INDUS_CL_SET_ID = 'GLTYPECDE' AND LEVEL_NUM = '1'                |
      | CATEGORY_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CATEGORY_CHECK  FROM FT_T_INCL WHERE CL_NME = '${VAR_CATEGORY}' AND CL_VALUE = '${VAR_CATEGORY}' AND INDUS_CL_SET_ID = 'CSHCTGCDE' AND LEVEL_NUM = '2'             |
      | SUB_CATEGORY_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SUB_CATEGORY_CHECK  FROM FT_T_INCL WHERE CL_NME = '${VAR_SUB_CATEGORY}' AND CL_VALUE = '${VAR_SUB_CATEGORY}' AND INDUS_CL_SET_ID = 'SUBCTGCDE' AND LEVEL_NUM = '3' |

     #IssueClassification table
    Examples: FT_T_ISCL Table Verifications
      | Column                 | Query                                                                                                                                                                                                                                                                                                                   |
      | CL_VALUE_CHECK         | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CL_VALUE_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}'AND CL_VALUE = '${VAR_GL_TYPE}'                                                                                                                                                           |
      | CLSF_OID_GL_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CLSF_OID_GL_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}'AND  CLSF_OID IN (SELECT CLSF_OID FROM FT_T_INCL WHERE CL_NME = '${VAR_GL_TYPE}' AND CL_VALUE = '${VAR_GL_TYPE}' AND INDUS_CL_SET_ID = 'GLTYPECDE' AND LEVEL_NUM = '1')                |
      | CLSF_OID_CTGY_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CLSF_OID_CTGY_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}'AND  CLSF_OID IN (SELECT CLSF_OID FROM FT_T_INCL WHERE CL_NME = '${VAR_CATEGORY}' AND CL_VALUE = '${VAR_CATEGORY}' AND INDUS_CL_SET_ID = 'CSHCTGCDE' AND LEVEL_NUM = '2')            |
      | CLSF_OID_SUBCTGY_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CLSF_OID_SUBCTGY_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}'AND  CLSF_OID IN (SELECT CLSF_OID FROM FT_T_INCL WHERE CL_NME = '${VAR_SUB_CATEGORY}' AND CL_VALUE = '${VAR_SUB_CATEGORY}' AND INDUS_CL_SET_ID = 'SUBCTGCDE' AND LEVEL_NUM = '3') |

 #IssueGeoUnit table
    Examples: FT_T_ISGU Table Verifications
      | Column           | Query                                                                                                                                                                                                                                                                  |
      | GU_ID_RISK_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GU_ID_RISK_CHECK  FROM FT_T_ISGU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_GU_PURP_TYP = 'RISK' AND GU_CNT = '1' AND GU_TYP='COUNTRY' AND DATA_STAT_TYP = 'ACTIVE' AND GU_ID = '${VAR_COUNTRY_OF_RISK}' |

 #IssueComment table
    Examples: FT_T_ISCM Table Verifications
      | Column                         | Query                                                                                                                                                                                                                                |
      | CMNT_TXT_LAST_UPD_TMS_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CMNT_TXT_LAST_UPD_TMS_CHECK FROM FT_T_ISCM WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CMNT_REAS_TYP = 'DWH_LAST_UPD_TMS' AND CMNT_TXT = '${VAR_DWH_LAST_UPD_TMS}'          |
      | CMNT_TXT_EXTRACT_BATCHID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CMNT_TXT_EXTRACT_BATCHID_CHECK FROM FT_T_ISCM WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CMNT_REAS_TYP = 'DWH_EXTRACT_BATCHID' AND CMNT_TXT = '${VAR_DWH_EXTRACT_BATCHID}' |

