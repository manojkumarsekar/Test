# =================================================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 10/05/2019      TOM-4574    GFCash to BNP - BrokerID FUNDTRF if Blank
# =================================================================================================

@gc_interface_cash
@dmp_regression_integrationtest
@tom_4574 @file96bnp
Feature: File96 file DMP load and generate outbound to BNP

  Scenario: Load and publish File96 from BRS to BNP

    Given I assign "tests/test-data/DevTest/TOM-4574" to variable "testdata.path"
    And I assign "esi_newcash_20190507_020006.xml" to variable "LOAD_NEW_CASH_FILE_NAME"
    And I assign "esi_bnp_cashalloc_file96" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "/dmp/out/bnp/intraday" to variable "PUBLISHING_DIR"

    And I execute below query
    """
    ${testdata.path}/sql/clearTestData.sql
    """

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