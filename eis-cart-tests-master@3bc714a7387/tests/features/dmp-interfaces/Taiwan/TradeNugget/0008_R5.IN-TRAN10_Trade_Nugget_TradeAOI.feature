# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 23/11/2018      TOM-3875    Second Version
# =====================================================================

@tom_3875 @tom_3875_aoi @esi_trade @esi_trade_aoi @tom_4101
Feature: Trades Inbound and Outbound. Test for Attributes Of Interest (AOI) functionality
# =====================================================================
# Load an Trade input file containing 6 records.
#   INVNUM: 301a_AT - This record is to test TRD_TRADE_DATE (EISExecutedTradeTrdDte)
#   INVNUM: 302a_AT - This record is to test TRD_ORIG_FACE (EISExecutedTradeSettlementAmount)
#   INVNUM: 303a_AT - This record is to test CUSIP (EISExecutedTradeIssueID)
#   INVNUM: 304a_AT - This record is to test PORTFOLIOS_PORTFOLIO_NAME (EISExecutedTradeCRTSPortfolioID)
#   INVNUM: 305a_AT - This record is to test TRAN_TYPE1/TRD_ORIG_FACE (EISExecutedTradeTrdSubType)
#   INVNUM: 306a_AT - This record is to test TRD_SETTLE_DATE, which is NOT an "Economics" field
# Publish SSDR Trades. Output will contain 6 records.
# Load the input file again, but with changes to the above fields
#   The first 5 records are to test the "Economics" field.
#   The 6th record is to test non-"Economics" field
# Publish SSDR Trades again. Output will contain 5 records.
# =====================================================================

# Step 1: Declare and assign variable
  Scenario: Set variables and run cleardown script
    Given I assign "ESI_Trade_003_AOI_Initial.xml" to variable "INPUT_FILENAME1"
    Given I assign "ESI_Trade_003_AOI_Modified.xml" to variable "INPUT_FILENAME2"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "esi_ssdr_trade_aoi_Initial" to variable "PUBLISHING_FILE_NAME1"
    And I assign "esi_ssdr_trade_aoi_Modified" to variable "PUBLISHING_FILE_NAME2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/ssdr" to variable "PUBLISHING_DIR"
    And I assign "esi_ssdr_trade_aoi_initial_master_template.csv" to variable "MASTER_FILE1"
    And I assign "esi_ssdr_trade_aoi_modified_master_template.csv" to variable "MASTER_FILE2"

# Step 2: Clear data for the given trades from ft_t_etcm, ft_t_trcp, ft_t_etag, ft_t_exst, ft_t_etid, ft_t_etam, ft_t_extr
    When I execute below query
"""
${testdata.path}/sql/0001_ClearDown.sql
"""

  Scenario: Trigger publishing wrapper to publish any pending Trades. Load a fresh set of trades and then publish

# Step 3: Delete the output file if it exist
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |

# Step 4: This step publishes and discards any previously loaded Trades that are yet to be published. Essentially this is a cleanup step
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME1}.csv  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

# Step 5: Delete and discard the output file if it exist - essentially a repeat of Step 3 above
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

# Step 6: Copy the input file to the input location
    When I copy files below from local folder "${testdata.path}/infiles/0006" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

# Step 7: Load a fresh set of 6 trades
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME1}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

# Step 7.1: Assert: are there 6 records in EXTR?
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "6":
    """
    SELECT COUNT(*) as RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

# Step 8: Publish SSDR - it should contain 6 trades
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME1}.csv  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

# Step 9: Validate whether output file is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

# Step 10: Copy the output file to reconcile data
    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv |

# Step 11: Reconcile Data. 6 trades should appear in output
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME1}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/template/${MASTER_FILE1}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

# Step 12: Copy the input file to the input location
    When I copy files below from local folder "${testdata.path}/infiles/0006" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

# Step 13: Re-Load the same set of 6 trades, but with changes to Economic field for first 5 records, and non-economic field for 6th record.
# This will result in 8 records in EXTR, i.e. 6 records from the previous load and an extra record each for '3547-301a_AT' and '3547-303a_AT with different TRD_TRADE_DATE and CUSIP, respectively from the new load
# Use the below query to see further...
# SELECT trd_id, last_chg_tms, trd_dte, instr_id
# FROM ft_t_extr
# WHERE trn_cde = 'BRSEOD'
# AND trd_id IN ('3547-301a_AT', '3547-303a_AT')
# ORDER BY trd_id, last_chg_tms

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME2}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM |

# Step 13.1: Assert: are there 7 records in EXTR?
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "7":
    """
    SELECT COUNT(*) as RECORD_COUNT FROM ft_t_extr WHERE trn_cde = 'BRSEOD' AND trd_id LIKE '%AT' AND end_tms IS NULL
    """

# Step 14: Publish SSDR - it should contain 5 trades. i.e. one record is not re-published because the changes to this record were on non-economic field
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME2}.csv  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SSDR_TRADE_SUB |
      | AOI_PROCESSING       | true                          |

# Step 15: Validate whether output file is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME2}_${VAR_SYSDATE}_1.csv |


