#https://jira.pruconnect.net/browse/EISDEV-6174
#https://collaborate.pruconnect.net/display/EISTOM/EIFFEL+III+Development+-+Credit+Tagging
#EISDEV_6174 : Initial Version
#EISDEV_6434 : As part of this feature file we need to check the population of child positions for MD_140722. These child records can be part of other securities as well.
#Keeping the reconcile only for MD_140722 records.
#EISDEV_7463 : added exchange rate columns to the exclusion list
#EISDEV-7580: Added additional clause of as_of_tms to pick only one balh getting loaded as part of the feature file

@gc_interface_securities @gc_interface_redi2
@dmp_regression_integrationtest
@eisdev_6174 @e3credtag_parentsec @eisdev_6434 @e3credtag @eisdev_7463 @eisdev_7580
Feature: Test UVAL for child position E3CreditTag classification

  This feature tests parent security E3CreditTag classification is present in UVAL file for child positions

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-6174" to variable "testdata.path"
    And I assign "/dmp/out/eis/redi2" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "1004_BNP_SecFile.out" to variable "INPUT_FILENAME_BNP"

  Scenario: Load BNP Security File and verify data is successfully processed

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_FILENAME_BNP}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_BNP} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY   |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Verification if E3 CREDIT TAG custom classification value is derived as per condition5 of java rule

    Then I expect value of column "E3CREDTAG_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as E3CREDTAG_COUNT
      FROM ft_T_iscl WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE iss_id = 'MD_140722' AND end_tms is null)
      AND INDUS_CL_SET_ID = 'E3CREDTAG' AND cl_value = 'Credit' AND end_tms IS NULL
      """

  Scenario: Publish REDI2 accrual report
    Given I assign "004_UVAL" to variable "PUBLISHING_FILENAME"
    Then I assign "004_UVAL_Expected" to variable "EXPECTED_FILENAME"

    And I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME}*.* |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME}.csv                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_REDI2_FEE_ACCRUAL_SUB                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | SQL                  | &lt;sql&gt; balh_oid in (select balh.balh_oid from fT_T_riss riss, ft_T_issu issu, ft_t_balh balh where rqstr_id = 'EOD' and org_id = 'EIS' and bk_id = 'EIS' and riss.RLD_ISS_FEAT_ID in (select RLD_ISS_FEAT_ID from fT_t_ridf where instr_id in (select instr_id from fT_T_isid where iss_id  ='MD_140722' and end_tms is null) and end_tms is null) and riss.end_tms is null and issu.instr_id = riss.instr_id and issu.end_tms is null and balh.instr_id= issu.instr_id and trunc(balh.as_of_tms) = to_date('20/04/2020','dd/mm/yyyy')) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |

    Then I exclude below columns from CSV file while doing reconciliations
      | file:${testdata.path}/outfiles/testdata/004_UVAL_Excluded_columns.txt |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${EXPECTED_FILENAME}.csv                   |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME}_${VAR_SYSDATE}_1.csv |
