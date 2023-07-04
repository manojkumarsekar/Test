#https://jira.intranet.asia/browse/TOM-3478

@gc_interface_cdf
@dmp_smoke
@tom_3478 @cdf_publishing @pvt @eisdev_6554 @brs_cdf
Feature: performance improvement for cdf publishing

  CDF publishing is taking more than 5 minutes to run which can be improved.
  Since, publishing job has max poll time of 300sec (5min),
  We can ensure job is taking less 5min if this test case passed

  Scenario: cdf publishing to improve performance

    Given I generate value with date format "DHMs" and assign to variable "VAR_RANDOM"
    And I assign "test_esi_cdf_pub_${VAR_RANDOM}" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Remove the file from publishing dir if exist

    Then I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
