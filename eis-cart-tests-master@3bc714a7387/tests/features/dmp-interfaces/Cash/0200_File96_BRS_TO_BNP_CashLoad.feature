# =================================================================================================
# Date            JIRA            Comments
# ============    ========        ========
# 11/06/2020      EISDEV-6420     Filter GF Cash Feed to BNP to remove estimated subscriptions/redemptions
# =================================================================================================

@gc_interface_cash
@dmp_regression_integrationtest
@eisdev_6420 @file96bnp
Feature: File96 file DMP load and generate outbound to BNP

  This scenario is to test the filtering of GF Cash feed to BNP for Taiwan accounts to remove estimated cash
  Taiwan Funds part of portfolio group TW_BNPSRK should be included
  |Portfolios           | E/F | Expectation                                                                           |
  |TT36,TT56,TT100      | F   | Reported as portfolios are member of TW_PROC and TW_BNPSRK                            |
  |NDMZAN,NDASAN,NDALIA |     | Reported as portfolios are not member of TW_PROC                                      |
  |TT17,TT23,TT37       |     | Not reported as portfolios are member of TW_PROC and but not of TW_BNPSRK             |
  |TT27                 | E   | Not reported as portfolios are member of TW_PROC, TW_BNPSRK and but cash is estimated |

  Scenario: Load and publish File96 from BRS to BNP

    Given I assign "tests/test-data/dmp-interfaces/Cash" to variable "testdata.path"
    And I assign "esi_newcash_20200611.xml" to variable "LOAD_NEW_CASH_FILE_NAME"
    And I assign "esi_bnp_cashalloc_file96" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/bnp/intraday" to variable "PUBLISHING_DIR"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_NEW_CASH_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash*.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_CASHALLOC_FILE96 |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.xml |

  Scenario: Reconciling template file with out file generated

    Given I assign "esi_bnp_cashalloc_file96_template.xml" to variable "TEMPLATE_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" to variable "OUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/reference/${TEMPLATE_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/exceptions_bnp_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
