# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/11/2018      TOM-3875    Second Version
# =====================================================================

@tom_3875 @tom_3875_excusion @esi_trade @esi_trade_exclusion
Feature: Trades Inbound and Outbound. Check for SSDR Exclusion functionality
# =====================================================================

  Scenario: Set variables and run cleardown script
    Given I assign "ESI_Trade_002_Exclusion.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "esi_ssdr_trade_exclusion_no_filter" to variable "PUBLISHING_FILE_NAME_NO_FILTER"
    And I assign "esi_ssdr_trade_exclusion_filter" to variable "PUBLISHING_FILE_NAME_FILTER"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/ssdr" to variable "PUBLISHING_DIR"
    And I assign "esi_ssdr_trade_exclusion_master_no_filter_template.csv" to variable "MASTER_FILE_NO_FILTER"
    And I assign "esi_ssdr_trade_exclusion_master_filter_template.csv" to variable "MASTER_FILE_FILTER"

  Scenario: Load and publish a set of Trades (after publishing any pre-existing trades) without any filter in ACGP

# Without Exclusion Filters
# Step 1: Clear data for the given trades from ft_t_etcm, ft_t_trcp, ft_t_etag, ft_t_exst, ft_t_etid, ft_t_etam, ft_t_extr
    When I execute below query
"""
${testdata.path}/sql/0001_ClearDown.sql
"""

# Step 2: Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_NO_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 3: This step publishes any previously loaded Trades that are yet to be published. Essentially this is a cleanup step
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_NO_FILTER}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB         |
      | AOI_PROCESSING       | true                                  |

# Step 4: Delete and discard the output file if it exist - essentially a repeat of Step 2 above
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_NO_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 5: Copy the input file to the input location
    When I copy files below from local folder "${testdata.path}/infiles/0006" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

# Step 6: Load a fresh set of 6 trades
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

# Step 7.1: Assert: are there 6 records in EXTR?
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) as RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

  # Step 7: Publish SSDR - it should contain 6 trades
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_NO_FILTER}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB         |
      | AOI_PROCESSING       | true                                  |

# Step 8: Validate whether output file is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_NO_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 9: Copy the file
    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_NO_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 10: Reconcile Data
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_NO_FILTER}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILE_NO_FILTER}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

# Repeat Steps 1-10, but this time with a filter in ACGP
  Scenario: Load and publish a set of Trades (after publishing any pre-existing trades) with filter in ACGP

# With Exclusion Filters
# Step 11: Clear data for the given trades from ft_t_etcm, ft_t_trcp, ft_t_etag, ft_t_exst, ft_t_etid, ft_t_etam, ft_t_extr
    When I execute below query
"""
${testdata.path}/sql/0001_ClearDown.sql
"""

# Step 12: Add a filter
    When I execute below query
"""
${testdata.path}/sql/0002_InsertACGP.sql
"""

# Step 13: Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 14: This step publishes any previously loaded Trades that are yet to be published. Essentially this is a cleanup step
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_FILTER}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB      |
      | AOI_PROCESSING       | true                               |

# Step 15: Delete and discard the output file if it exist
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 16: Copy input file
    When I copy files below from local folder "${testdata.path}/infiles/0006" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

# Step 17: Load a fresh set of 6 trades
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

# Step 17.1: Assert: are there 6 records in EXTR?
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) as RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

# Step 18: Publish SSDR - it should contain 6 trades
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_FILTER}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB      |
      | AOI_PROCESSING       | true                               |

# Step 19: Validate that output is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 20: Copy the file
    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_FILTER}_${VAR_SYSDATE}_1.csv |

# Step 21:  Reconcile Data. Fund ALATRF should get filtered out
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_FILTER}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILE_FILTER}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file