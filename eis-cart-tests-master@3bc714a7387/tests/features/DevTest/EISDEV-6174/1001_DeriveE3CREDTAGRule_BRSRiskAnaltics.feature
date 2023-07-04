#https://jira.pruconnect.net/browse/EISDEV-6174
#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#eisdev-6341: Changes done to make feature file re-runnable
#eisdev-6896: As part for eisdev-6670, RIC is added to the primary identifier. Due to this
# instead of 2 different securities, single security was getting created based on matching from RIC.
# Removing RIC from test data.
#eisdev-7580: Added additional clause of as_of_tms to pick only one balh getting loaded as part of the feature file

@gc_interface_securities @gc_interface_risk_analytics @gc_interface_positions @gc_interface_redi2
@dmp_regression_integrationtest
@eisdev_6174 @e3credtag_brs @eisdev_6341 @e3credtag @eisdev_6896 @eisdev_7435 @eisdev_7580
Feature: Test derivation of E3CreditTag classification for BRS conditions

  This feature tests derivation of E3CreditTag classification for BRS conditions from java rule and publish UVAL with derived column added
  COND1 : IF ESI_CORE_L2 = Cash, Treasury Bill, Treasury Strip, Inflation Linked THEN E3CREDTAG = Non Credit
  COND2 : IF ESI_CORE_L2 = "Government" AND security currency = local currency of country THEN E3CREDTAG = Non Credit
  COND3 : IF Sec Group = "FUTURE" AND FUTURE_CLASS = "GBOND" THEN E3CREDTAG=Non Credit
  COND4 : IF ESI_CORE_L2 = "Other" and security does not belongs to the one of the following:
  SECGROUP    SECTYPE   FUTURECLASS
  CASH	      FXFWRD
  BND	      CORP
  OPTION	  OTC
  SYNTH	      CAP
  EQUITY	  EQUITY
  FUTURE	  GENERIC	  CBOND
  BND	      LOCAL
  THEN E3CREDTAG = blank and Excpetion raised

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "BRS_File10_GBOND.xml" to variable "INPUT_FILENAME_BRS"
    And I assign "BRS_File10_cond4.xml" to variable "INPUT_FILENAME_BRS_COND4"
    And I assign "risk_analytics_cond1.xml" to variable "INPUT_FILENAME_COND1"
    And I assign "risk_analytics_cond2.xml" to variable "INPUT_FILENAME_COND2"
    And I assign "risk_analytics_cond3.xml" to variable "INPUT_FILENAME_COND3"
    And I assign "risk_analytics_cond4.xml" to variable "INPUT_FILENAME_COND4"
    And I assign "001_POS_FILE.xml" to variable "INPUT_FILENAME_position"
    And I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: End date Instruments in GC and VD DB

    Given I inactivate "E3CredTagSCN1" instruments in GC database
    Given I inactivate "E3CredTagSCN1" instruments in VD database

  Scenario: Clear the Classification for the selected instrument

    And I execute below query to "Clear data for the given instrument from FT_T_ISCL"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG', 'FUTCLASS') AND end_tms IS NULL
    """

  Scenario: Load BRS File10 and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BRS}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if FUTURE_CLASS field is loaded in table FT_T_ISCL sucessfully

    Then I expect value of column "FUTCLASS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as FUTCLASS_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'FUTCLASS' AND cl_value = 'GBOND' AND end_tms IS NULL
      """

  Scenario: Load Risk Analytics files and verify data is successfully processed

    Then I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_COND1}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_COND1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition1 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: Load Risk Analytics files and verify data is successfully processed

    Given I execute below query to "Clear data for the given instrument from FT_T_ISCL for E3CREDTAG"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_COND2}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_COND2}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition2 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: Load Risk Analytics files and verify data is successfully processed

    Given I execute below query to "Clear data for the given instrument from FT_T_ISCL for E3CREDTAG"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_COND3}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_COND3}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition3 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN1' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: Load BRS File10 and verify data is successfully processed

    Then I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BRS_COND4}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_COND4} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW     |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if FUTURE_CLASS field is loaded in table FT_T_ISCL sucessfully

    Then I expect value of column "FUTCLASS_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) as FUTCLASS_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN4' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'FUTCLASS' AND cl_value = 'GBOND' AND end_tms IS NULL
      """

  Scenario: Load Risk Analytics files and verify data is successfully processed

    Given I execute below query to "Clear data for the given instrument from FT_T_ISCL for E3CREDTAG"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN4' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_COND4}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_COND4}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition4 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'E3CredTagSCN4' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND CL_VALUE  = 'Exception' and end_tms IS NULL
      """

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60034'
      AND APPL_ID = 'STRDATA'
      AND PART_ID = 'RULEPRC'
      AND MAIN_ENTITY_ID = 'E3CredTagSCN4-AHP5WB'
      AND MSG_SEVERITY_CDE = 40
      AND PARM_VAL_TXT = 'E3 Credit Tag Derivation:For ESICRESCT Level2 Classification as OTHER - secgrp,secType,futClass combination exception.'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

  #Test Publish records in UVAL file
  Scenario: Load position file using message type EIS_MT_BRS_EOD_POSITION_LATAM and verify records in DMP - SECURITY - E3CredTagSCN1

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_position}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_position}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Create Cross Rates

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "CREATE_RATES"

    And I process the workflow template file "${CREATE_RATES}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_fxrt_cross_rates |

  Scenario: Publish REDI2 accrual report
    Given I assign "001_UVAL" to variable "PUBLISHING_FILENAME"
    Then I assign "001_UVAL_Expected" to variable "EXPECTED_FILENAME"

    And I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | *UVAL*.* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME}.csv                                                                                                                                                                                                                                                                                                                                                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_REDI2_FEE_ACCRUAL_SUB                                                                                                                                                                                                                                                                                                                                                                                               |
      | SQL                  | &lt;sql&gt; balh_oid in (select balh_oid from ft_t_balh where rqstr_id = 'BRSEOD' and org_id = 'EIS' and bk_id = 'EIS' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_typ = 'CRTSID' and acct_alt_id = 'ARBRUF' and end_tms is null) and instr_id in (SELECT instr_id FROM ft_t_isid WHERE iss_id in ( 'E3CredTagSCN1') AND end_tms is null) and as_of_tms = to_date('10/15/2005','MM/DD/YYYY'))&lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${EXPECTED_FILENAME}.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file
