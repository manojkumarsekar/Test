# =================================================================================================
# Date            JIRA            Comments
# ============    ========        ========
# 29/06/2020      EISDEV-6557     Changes for PaymentType when REASON = DOPTRANSFER
# 06/07/2020      EISDEV-6584     REASON to be changed from DOPTRANSFER to DOPTRANS
# =================================================================================================

@gc_interface_cash
@dmp_regression_integrationtest
@eisdev_6557 @file96bnp @eisdev_6584
Feature: File96 file DMP load and generate outbound to BNP for REASON = DOPTRANS

  AUTO661725 : Verify PaymentType is published as CASHOUT as the transaction is for portfolio with investment manager JP
  AUTO661714 : Verify PaymentType is published as CASHIN as the transaction is for portfolio with investment manager JP
  AUTO407050 : Verify PaymentType is published as PAYMENT as the transaction is for investment manager SG and reason is DOPTRANS
  AUTO407043 : Verify PaymentType is published as RECEIPT as the transaction is for investment manager SG and reason is DOPTRANS
  AUTO425843 : Verify PaymentType is published as CASHOUT as the transaction is for investment manager SG and reason is REDS
  AUTO425844 : Verify PaymentType is published as CASHIN as the transaction is for investment manager SG and reason is SUBS

  Scenario: Cleanup

    Given I execute below query to "update trade id in extr to re-run this feature file"
    """
    UPDATE FT_T_EXTR SET TRD_ID = NEW_OID() WHERE TRD_ID like 'AUTO%' and TRN_CDE = 'CSHALL96';
    COMMIT
    """

  Scenario: Load and publish File96 from BRS to BNP

    Given I assign "tests/test-data/dmp-interfaces/Cash" to variable "testdata.path"
    And I assign "esi_newcash_dop.xml" to variable "LOAD_NEW_CASH_FILE_NAME"
    And I assign "esi_bnp_cashalloc_file96_dop" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/intraday" to variable "PUBLISHING_DIR"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${LOAD_NEW_CASH_FILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | esi_newcash_dop*.xml        |
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
      | ${PUBLISHING_FILE_NAME}*.xml |

  Scenario: Reconciling template file with out file generated

    Given I assign "esi_bnp_cashalloc_file96_dop_template.xml" to variable "TEMPLATE_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" to variable "OUT_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/reference/${TEMPLATE_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/exceptions_bnp_${recon.timestamp}.csv" file