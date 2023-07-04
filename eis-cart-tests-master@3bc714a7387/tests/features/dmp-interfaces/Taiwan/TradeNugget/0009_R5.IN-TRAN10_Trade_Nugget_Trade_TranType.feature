# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/11/2018      TOM-3875    First Version
# =====================================================================

@tom_3875 @tom_3875_trans_type1 @esi_trade @esi_trade_TRAN_TYPE1 @tom_4107
Feature: Trades Inbound and Outbound. Check for additional TRAN_TYPE1. TRD, MAT, ISSU
# =====================================================================
# Load an Trade input file containing 2 records. Each of these  records has TRAN_TYPE1 TRD, MAT

# Step 1: Declare and assign variable
  Scenario: Set variables and run cleardown script
    Given I assign "ESI_Trade_004_TRAN_TYPE1.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "esi_ssdr_trade_tran_type" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/ssdr" to variable "PUBLISHING_DIR"
    And I assign "esi_ssdr_trade_tran_type_master_template.csv" to variable "MASTER_FILE"

# Step 2: Clear data for the given trades from ft_t_etcm, ft_t_trcp, ft_t_etag, ft_t_exst, ft_t_etid, ft_t_etam, ft_t_extr
    When I execute below query
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

# Step 7: Load a fresh set of 2 trades
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

# Step 7.1: Assert: are there 4 records in EXTR?
    Then I expect value of column "TOTAL_RECORD_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) as TOTAL_RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

# Step 7.1: Assert: are there 2 records in EXTR FOR TRANS_TYPE = 'TRD'?
    Then I expect value of column "TRD_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) as TRD_RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT'  AND EXEC_TRN_CAT_TYP ='TRD' AND end_tms IS NULL
    """
# Step 7.2: Assert: are there 2 records in EXTR FOR TRANS_TYPE = 'MAT'?
    Then I expect value of column "MAT_RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) as MAT_RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND EXEC_TRN_CAT_TYP ='MAT' AND end_tms IS NULL
    """
# Step 8: Publish SSDR - it should contain only 2 records (TRAN_TYPE1 = TRD)
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

# Step 11: Reconcile Data. Only one record should get published (TRAN_TYPE1 = TRD)
     And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file