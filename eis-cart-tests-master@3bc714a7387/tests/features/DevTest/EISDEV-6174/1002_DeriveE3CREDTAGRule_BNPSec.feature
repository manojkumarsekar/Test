#https://jira.pruconnect.net/browse/EISDEV-6174
#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging

#EISDEV-7580: Added additional clause of as_of_tms to pick only one balh getting loaded as part of the feature file

@gc_interface_securities @gc_interface_positions @gc_interface_redi2
@dmp_regression_integrationtest
@eisdev_6174 @e3credtag_bnp @e3credtag @eisdev_7435 @eisdev_7580
Feature: Test derivation of E3CreditTag classification for BNP conditions and publish UVAL

  This feature tests derivation of E3CreditTag classification for BNP conditions from java rule and publish UVAL with derived column added
  COND1 : IF BCAT_DESC starts with = "CAP - ....." AND NOT "CAP - Collateral Account" THEN E3CREDTAG = Non Credit
  COND2 : IF BSIT_P9 = FX Spot THEN E3CREDTAG = Non Credit
  COND3 : IF BSIT_P2 = "Futures" AND BSIT_P4 = "Debt instrumnets" THEN E3CREDTAG = Non Credit
  ELSE E3CREDTAG = Credit

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "BNP_SecFile_BCATDesc_cond5.out" to variable "INPUT_FILENAME_BNP_cond5"
    And I assign "BNP_SecFile_BSITP9_cond6.out" to variable "INPUT_FILENAME_BNP_cond6"
    And I assign "BNP_SecFile_BSITP2P4_cond7.out" to variable "INPUT_FILENAME_BNP_cond7"
    And I assign "002_POS_FILE.xml" to variable "INPUT_FILENAME_position"
    And I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Clear the Classification for the selected instrument

    And I execute below query to "Clear data for the given instruments from FT_T_ISCL"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_378491_COND5' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I inactivate "'MD_378491_COND5'" instruments in GC database
    Then I inactivate "'MD_378491_COND5'" instruments in VD database

  Scenario: Load BNP Security File and verify data is successfully processed

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BNP_cond5}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP_cond5} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition5 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_378491_COND5' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: Clear the Classification for the selected instrument

    And I execute below query to "Clear data for the given instruments from FT_T_ISCL"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_266767_COND6' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I inactivate "'MD_266767_COND6'" instruments in GC database
    Then I inactivate "'MD_266767_COND6'" instruments in VD database

  Scenario: Load BNP Security File and verify data is successfully processed

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BNP_cond6}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP_cond6} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition6 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_266767_COND6' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  Scenario: Clear the Classification for the selected instrument

    And I execute below query to "Clear data for the given instruments from FT_T_ISCL"
    """
    DELETE FROM ft_t_iscl
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_483032_COND7' AND end_tms is null)
    AND INDUS_CL_SET_ID in('E3CREDTAG') AND end_tms IS NULL
    """

    Then I inactivate "'MD_483032_COND7'" instruments in GC database
    Then I inactivate "'MD_483032_COND7'" instruments in VD database

  Scenario: Load BNP Security File and verify data is successfully processed

    When I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BNP_cond7}" file with below parameters
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP_cond7} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY         |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition7 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_483032_COND7' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Non Credit' AND end_tms IS NULL
      """

  #Test Publish records in UVAL file
  Scenario: Load position file using message type EIS_MT_BRS_EOD_POSITION_LATAM and verify records in DMP

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_position}" file with below parameters
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${INPUT_FILENAME_position}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario: Create Cross Rates

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "CREATE_RATES"

    And I process the workflow template file "${CREATE_RATES}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_fxrt_cross_rates |

  Scenario: Publish REDI2 accrual report
    Given I assign "002_UVAL" to variable "PUBLISHING_FILENAME"
    Then I assign "002_UVAL_Expected" to variable "EXPECTED_FILENAME"

    And I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | *UVAL*.* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME}.csv                                                                                                                                                                                                                                                                                                                                                                                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_REDI2_FEE_ACCRUAL_SUB                                                                                                                                                                                                                                                                                                                                                                                               |
      | SQL                  | &lt;sql&gt; balh_oid in (select balh_oid from ft_t_balh where rqstr_id = 'BRSEOD' and org_id = 'EIS' and bk_id = 'EIS' and acct_id in (select acct_id from ft_t_acid where acct_id_ctxt_typ = 'CRTSID' and acct_alt_id in ('ARBRUF','ALALBF') and end_tms is null) and instr_id in (SELECT instr_id FROM ft_t_isid WHERE iss_id in ( 'MD_378491_COND5','MD_266767_COND6','MD_483032_COND7') AND end_tms is null)) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/testdata/${EXPECTED_FILENAME}.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file