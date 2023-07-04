# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/11/2018      TOM-3875    Second Version
# =====================================================================

@gc_interface_trades @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3875 @tom_3875_timezone @esi_trade @esi_trade_timezone
Feature: Trades Inbound and Outbound. Check for TimeZone functionality

  =====================================================================
  Load an Trade input file containing 6 records. Each of these 6 records test the border conditions of BST. Publish SSDR Trades outbound. It should contan 6 records
  TRD_ENTRY_TIME = 3/15/2017 1:00:00    : Load Record where TRD_ENTRY_TIME is much before to BST start date. SGT will be calculated as  +8. Expected Result     : 3/15/2017 9:00:00
  TRD_ENTRY_TIME = 3/26/2017 0:59:59    : Load Record where TRD_ENTRY_TIME is just before to BST start date. SGT will be calculated as  +8. Expected Result     : 3/26/2017 8:59:59
  TRD_ENTRY_TIME = 3/26/2017 2:00:00    : Load Record where TRD_ENTRY_TIME is spot on the BST start date. SGT will be calculated as  +7. Expected Result        : 3/26/2017 9:00:00
  TRD_ENTRY_TIME = 4/15/2017 1:00:00    : Load Record where TRD_ENTRY_TIME is much after on the BST start date. SGT will be calculated as  +7. Expected Result  : 4/15/2017 8:00:00
  TRD_ENTRY_TIME = 10/29/2017 0:59:59   : Load Record where TRD_ENTRY_TIME is just before on the BST end date. SGT will be calculated as  +7. Expected Result   : 10/29/2017 7:59:59
  TRD_ENTRY_TIME = 10/31/2017 1:00:00   : Load Record where TRD_ENTRY_TIME is much after the BST end date. SGT will be calculated as +8. Expected Result        : 10/31/2017 9:00:00
  =====================================================================

  Scenario: Set variables and run cleardown script

    Given I assign "ESI_Trade_001_TimeZone.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "esi_ssdr_trade_time_zone" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/ssdr" to variable "PUBLISHING_DIR"
    And I assign "esi_ssdr_trade_time_zone_master_template.csv" to variable "MASTER_FILE"

    When I execute below query to "Clear data for the given trades from ft_t_etcm, ft_t_trcp, ft_t_etag, ft_t_exst, ft_t_etid, ft_t_etam, ft_t_extr"
    """
    ${testdata.path}/sql/0001_ClearDown.sql
    """

  Scenario: Trigger publishing wrapper to publish any pending Trades. Load a fresh set of trades and then publish

    # Step 3: Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    # Step 4: This step publishes and discards any previously loaded Trades that are yet to be published. Essentially this is a cleanup step
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

    # Step 5: Delete and discard the output file if it exist - essentially a repeat of Step 3 above
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    # Step 6: Copy the input file to the input location
    When I copy files below from local folder "${testdata.path}/infiles/0006" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    # Step 7: Load a fresh set of 6 trades
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

    # Step 7.1: Assert: are there 6 records in EXTR?
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) as RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

    # Step 8: Publish SSDR - it should contain 6 trades
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

    # Step 9: Validate whether output file is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    # Step 10: Copy the output file to reconcile data
    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    # Step 11: Reconcile Data. Trade time should get translated to SGT
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file