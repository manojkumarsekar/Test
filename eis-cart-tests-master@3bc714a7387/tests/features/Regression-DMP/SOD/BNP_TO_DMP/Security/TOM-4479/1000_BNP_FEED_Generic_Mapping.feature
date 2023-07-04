#Ticket link : https://jira.intranet.asia/browse/TOM-4479
#Parent Ticket: https://jira.intranet.asia/browse/TOM-1226
#Requirement Links: https://collaborate.intranet.asia/pages/viewpage.action?pageId=14796607#Test-logicalMapping
#https://jira.pruconnect.net/browse/EISDEV-7308
#EXM Rel 9 - Removing IEDF scenarios as only UPDATE is applicable for BNP

@gc_interface_securities
@dmp_regression_unittest
@1000_tom_4479_bnp_dmp_security @eisdev_7308
Feature: BNP to DMP Security feed - Field Mapping - Generic Fields

  Description of the feature:
  As a part of this feature, we are testing:
  1. Loading Security Feed (with Fixed Income data)
  2. Validating Common fields mapping for Security tables as per Specifications

  Scenario: Assign Variables

    Given I assign "tests/test-data/Regression-DMP/SOD/BNP_TO_DMP/Security/TOM-4479" to variable "testdata.path"

    And I assign "ESISODP_SEC_FI_LOAD.out" to variable "INPUT_FILENAME"

    And I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/testdata" and assign to variables:
      | INSTR_ID            | VAR_INSTR_ID            |
      | ISIN                | VAR_ISIN                |
      | SEDOL               | VAR_SEDOL               |
      | HIP_SECURITY_CODE   | VAR_HIP_SECURITY_CODE   |
      | SOURCE_ID           | VAR_SOURCE_ID           |
      | INSTR_LONG_NAME     | VAR_INSTR_LONG_NAME     |
      | INSTR_SHORT_NAME    | VAR_INSTR_SHORT_NAME    |
      | INSTR_TYPE          | VAR_INSTR_TYPE          |
      | COUPON_TYPE         | VAR_COUPON_TYPE         |
      | ISSUE_CCY           | VAR_ISSUE_CCY           |
      | TRADEABLE_QTY       | VAR_TRADEABLE_QTY       |
      | COUNTRY_OF_RISK     | VAR_COUNTRY_OF_RISK     |
      | COUNTRY_OF_ISSUE    | VAR_COUNTRY_OF_ISSUE    |
      | COUPON_FREQUENCY    | VAR_COUPON_FREQUENCY    |
      | COUPON_RATE         | VAR_COUPON_RATE         |
      | DAY_COUNT_BASIS     | VAR_DAY_COUNT_BASIS     |
      | EXPOSURE_CCY        | VAR_EXPOSURE_CCY        |
      | FIRST_COUPON_DATE   | VAR_FIRST_COUPON_DATE   |
      | FIXED_FLOATING_IND  | VAR_FIXED_FLOATING_IND  |
      | INDEX_RATIO         | VAR_INDEX_RATIO         |
      | INTEREST_MARGIN     | VAR_INTEREST_MARGIN     |
      | DWH_LAST_UPD_TMS    | VAR_DWH_LAST_UPD_TMS    |
      | DWH_EXTRACT_BATCHID | VAR_DWH_EXTRACT_BATCHID |
      | SINKING_FUND_IND    | VAR_SINKING_FUND_IND    |
      | PRIMARY_EXCHANGE    | VAR_PRIMARY_EXCHANGE    |
      | NEXT_COUPON_DATE    | VAR_NEXT_COUPON_DATE    |
      | MATURITY_DATE       | VAR_MATURITY_DATE       |
      | ISSUE_DATE          | VAR_ISSUE_DATE          |

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${VAR_INSTR_ID}','${VAR_ISIN}','${VAR_SEDOL}','${VAR_HIP_SECURITY_CODE}'"

  Scenario: Load Security File

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |

    And I execute below query and extract values of "INSTRUMENT_ID" into same variables
    """
    SELECT INSTR_ID AS INSTRUMENT_ID FROM FT_T_ISID WHERE ISS_ID IN ('${VAR_INSTR_ID}') AND END_TMS IS NULL
    """

  Scenario Outline: BNP Security Feed Validations for <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
    <Query>
    """

 #Issue table -- Security master table
    Examples: FT_T_ISSU Table Verifications
      | Column               | Query                                                                                                                                                                                                        |
      | PREF_ISS_DESC_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PREF_ISS_DESC_CHECK FROM  FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PREF_ISS_DESC = '${VAR_INSTR_LONG_NAME}'                            |
      | PREF_ISS_NME_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PREF_ISS_NME_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PREF_ISS_NME = '${VAR_INSTR_SHORT_NAME}'                              |
      | ISS_TYPE_CHECK       | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_TYPE_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}'                                                                               |
      | DENOM_CURR_CDE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS DENOM_CURR_CDE_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND DENOM_CURR_CDE = '${VAR_ISSUE_CCY}'                                 |
      | MAT_EXP_TMS_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MAT_EXP_TMS_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND MAT_EXP_TMS = TO_DATE('${VAR_MATURITY_DATE}','YYYY-MM-DD')             |
      | ISS_TMS_CHECK        | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_TMS_CHECK FROM FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_TMS = TO_DATE('${VAR_ISSUE_DATE}','YYYY-MM-DD')                        |
      | PREF_ISS_ID_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PREF_ISS_ID_CHECK FROM  FT_T_ISSU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PREF_ISS_ID = '${VAR_INSTR_ID}' AND  PREF_ID_CTXT_TYP IN ('BNPLSTID') |

 #IssueIdentifier table
    Examples: FT_T_ISID Table Verifications
      | Column          | Query                                                                                                                                                           |
      | BNPLSTID_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BNPLSTID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'BNPLSTID'     |
      | BBGLSTID_CHECK  | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BBGLSTID_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'BNP_BBGLOBAL' |
      | HIPSECCDE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS HIPSECCDE_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'HIPSECCDE'   |
      | SEDOL_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SEDOL_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP = 'SEDOL'           |
      | ISIN_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISIN_CHECK FROM FT_T_ISID WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ID_CTXT_TYP='ISIN'               |
      | CPN_TYP_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_TYP_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_TYP = 'FIXED'             |

 #IssueDescription table
    Examples: FT_T_ISDE Table Verifications
      | Column             | Query                                                                                                                                                                           |
      | ISS_DESC_CHECK     | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_DESC_CHECK FROM FT_T_ISDE WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_DESC = '${VAR_INSTR_LONG_NAME}'          |
      | ISS_NME_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_NME_CHECK FROM FT_T_ISDE WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_NME = '${VAR_INSTR_SHORT_NAME}'           |
      | ISS_SHRT_NME_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISS_SHRT_NME_CHECK FROM FT_T_ISDE WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_SHRT_NME = '${VAR_INSTR_SHORT_NAME}' |

 #IssueStatistic table
    Examples: FT_T_ISST Table Verifications
      | Column                      | Query                                                                                                                                                                                                                  |
      | STAT_CHAR_VAL_TXT_SID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS STAT_CHAR_VAL_TXT_SID_CHECK FROM FT_T_ISST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND STAT_DEF_ID = 'SORCEID' AND STAT_CHAR_VAL_TXT = '${VAR_SOURCE_ID}'     |
      | STAT_CHAR_VAL_TXT_CCY_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS STAT_CHAR_VAL_TXT_CCY_CHECK FROM FT_T_ISST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND STAT_DEF_ID = 'CURRENCY' AND STAT_CHAR_VAL_TXT = '${VAR_EXPOSURE_CCY}' |

 #IssueClassification table
    Examples: FT_T_ISCL Table Verifications
      | Column         | Query                                                                                                                                                                                                                                                                                                        |
      | CL_VALUE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CL_VALUE_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}'AND  INDUS_CL_SET_ID = 'BNPSECTYPE' AND CL_VALUE = '${VAR_INSTR_TYPE}'                                                                                                         |
      | CLSF_OID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CLSF_OID_CHECK FROM FT_T_ISCL WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CLSF_OID IN (SELECT CLSF_OID FROM FT_T_INCL WHERE CL_VALUE = '${VAR_INSTR_TYPE}' AND CL_NME = '${VAR_INSTR_TYPE}' AND INDUS_CL_SET_ID = 'BNPSECTYPE' AND LEVEL_NUM = '1') |

 #IssueGeoUnit table
    Examples: FT_T_ISGU Table Verifications
      | Column              | Query                                                                                                                                                                                                                                           |
      | PART_CURR_CDE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PART_CURR_CDE_CHECK FROM FT_T_ISGU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND PART_CURR_CDE = '${VAR_EXPOSURE_CCY}'                                                                   |
      | GU_ID_RISK_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GU_ID_RISK_CHECK  FROM FT_T_ISGU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_GU_PURP_TYP = 'RISK' AND GU_CNT = '1' AND GU_TYP='COUNTRY' AND GU_ID = '${VAR_COUNTRY_OF_RISK}'       |
      | GU_ID_ISSUE_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GU_ID_ISSUE_CHECK  FROM FT_T_ISGU WHERE INSTR_ID = '${INSTRUMENT_ID}' AND ISS_GU_PURP_TYP = 'DOMICILE' AND GU_CNT = '1' AND GU_TYP='COUNTRY' AND GU_ID = '${VAR_COUNTRY_OF_ISSUE}' |

 #IssueComment table
    Examples: FT_T_ISCM Table Verifications
      | Column                         | Query                                                                                                                                                                                                                                |
      | CMNT_TXT_LAST_UPD_TMS_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CMNT_TXT_LAST_UPD_TMS_CHECK FROM FT_T_ISCM WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CMNT_REAS_TYP = 'DWH_LAST_UPD_TMS' AND CMNT_TXT = '${VAR_DWH_LAST_UPD_TMS}'          |
      | CMNT_TXT_EXTRACT_BATCHID_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CMNT_TXT_EXTRACT_BATCHID_CHECK FROM FT_T_ISCM WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CMNT_REAS_TYP = 'DWH_EXTRACT_BATCHID' AND CMNT_TXT = '${VAR_DWH_EXTRACT_BATCHID}' |

 #MarketIssueCharacteristics table
    Examples: FT_T_MKIS Table Verifications
      | Column                  | Query                                                                                                                                                                                                                                             |
      | TRDNG_CURR_CDE_CHECK    | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRDNG_CURR_CDE_CHECK FROM FT_T_MKIS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND TRDNG_CURR_CDE = '${VAR_ISSUE_CCY}'                                                                      |
      | TRD_LOT_SIZE_CQTY_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TRD_LOT_SIZE_CQTY_CHECK FROM FT_T_MKIS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND TRD_LOT_SIZE_CQTY = '${VAR_TRADEABLE_QTY}'                                                            |
      | MKT_OID_CHECK           | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MKT_OID_CHECK FROM FT_T_MKIS WHERE INSTR_ID = '${INSTRUMENT_ID}' AND MKT_OID IN (SELECT MKT_OID FROM FT_T_MKID WHERE MKT_ID = '${VAR_PRIMARY_EXCHANGE}' AND MKT_ID_CTXT_TYP = 'MIC') |


 #DebtInstrumentStatistics table
    Examples: FT_T_BDST Table Verifications
      | Column                       | Query                                                                                                                                                                                               |
      | CPN_CRTE_CHECK               | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_CRTE = '${VAR_COUPON_RATE}'                                  |
      | INDX_CRTE_CHECK              | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS INDX_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND INDX_CRTE = '${VAR_INDEX_RATIO}'                                |
      | CRRNT_IN_RTE_MRGN_CRTE_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CRRNT_IN_RTE_MRGN_CRTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CRRNT_IN_RTE_MRGN_CRTE = '${VAR_INTEREST_MARGIN}'  |
      | NXT_CPN_DTE_CHECK            | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NXT_CPN_DTE_CHECK FROM FT_T_BDST WHERE INSTR_ID = '${INSTRUMENT_ID}' AND NXT_CPN_DTE = TO_DATE('${VAR_NEXT_COUPON_DATE}','YYYY-MM-DD') |


 #DebtInstrumentCharacteristics table
    Examples: FT_T_BDCH Table Verifications
      | Column             | Query                                                                                                                                                                           |
      | EX_DIV_IND_CHECK   | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS EX_DIV_IND_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND EX_DIV_IND = 'C'                           |
      | SINKABLE_IND_CHECK | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SINKABLE_IND_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND SINKABLE_IND = '${VAR_SINKING_FUND_IND}' |
      | CPN_TYP_CHECK      | SELECT CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS CPN_TYP_CHECK FROM FT_T_BDCH WHERE INSTR_ID = '${INSTRUMENT_ID}' AND CPN_TYP = 'FIXED'                             |
    
	
