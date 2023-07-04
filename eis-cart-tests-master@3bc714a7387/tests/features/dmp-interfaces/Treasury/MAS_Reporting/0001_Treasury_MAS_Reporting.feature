# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 15/11/2019      EISDEV-5174    Initial Version
# 01/02/2020      EISDEV-5544    Initial Version
# =====================================================================
#https://jira.pruconnect.net/browse/EISDEV-5174 - This ticket is for Treasury - MAS Reporting Outbound
#https://jira.pruconnect.net/browse/EISDEV-5460 - This ticket is for adding additional fields for MAS reporting

#https://jira.pruconnect.net/browse/EISDEV-5544 - This ticket is to modify the logic for "Action- Trade" and "LifeCycle Event"
# when there was any modification in trades received , we use to populate ActionTrade as "Modify" .
# Since as a value modify is getting rejected not acceptable by DTCC , so for any trade modification received ,
# we are populating ActionTrade as "New" and LifeCycleEvent as "Modify"

@gc_interface_treasury @gc_interface_issuer @gc_interface_counterparty @gc_interface_securities
@dmp_regression_integrationtest
@tom_5174 @eisdev_5460 @eisdev_5544 @treasury @mas
Feature: MAS Reporting Inbound and Outbound

  Test #1: Load a Trade file containing 3 trades.
  Trade 1 has Portfolio = 'GTFXHED and 'Counterparty = 'BNYM-GT' and Security Type 'FUND/STIF'
  Trade 2 has Portfolio = 'GTFXHED and Counterparty = 'SCB-ES' and Security Type 'FX/SPOT'
  Trade 3 has Portfolio = 'GTFXHED and Counterparty = 'SCB-ES' and Security Type 'FX/FWRD'
  Requirement is to publish those trades where Portfolio = 'GTFXHED' and Counterparty in (SCB-ES,MSTC-ES,JPM-ES,HSBC-ES,,GOLD-ES,DMGN-ES,CITI-ES,BOA-ES,BNYM-ES,BNP-ES,BCM-ES) and Security Type 'FX/FWRD'

  Test #2: Load a Trade file containing 1 trade.
  Trade 3 has Portfolio = 'GTFXHED and Counterparty = 'SCB-ES' and Security Type 'FX/FWRD'. Notional amount (which is an AOI field) is updated
  Requirement is to publish the trade where Portfolio = 'GTFXHED' and Counterparty = 'SCB-ES' and Security Type 'FX/FWRD' and AOI field is updated

  Test #3: Load a Trade file containing 1 trade.
  Trade 3 has Portfolio = 'GTFXHED and Counterparty = 'SCB-ES' and Security Type 'FX/FWRD'. Trade Series Number field (which is NOT an AOI field) is updated
  Requirement is to NOT publish the trade where Portfolio = 'GTFXHED' and Counterparty = 'SCB-ES' and Security Type 'FX/FWRD' and non-AOI field is updated

  Scenario: Assign variables

    Given I assign "5174_issuer.xml" to variable "INPUT_ISSUER_FILENAME"
    And I assign "5174_broker.xml" to variable "INPUT_BROKER_FILENAME"
    And I assign "5174_sm.xml" to variable "INPUT_SECURITY_FILENAME"

    And I assign "5174_transaction_original.xml" to variable "INPUT_TRADE_ORIGINAL"
    And I assign "5174_transaction_modified_AOI.xml" to variable "INPUT_TRADE_MODIFIED_AOI"
    And I assign "5174_transaction_modified_NON_AOI.xml" to variable "INPUT_TRADE_MODIFIED_NON_AOI"

    And I assign "tests/test-data/dmp-interfaces/Treasury/MAS_Reporting" to variable "testdata.path"
    And I assign "mas_trades_discard" to variable "PUBLISHING_FILE_NAME_DISCARD"
    And I assign "mas_trades_original" to variable "PUBLISHING_FILE_NAME_ORIGINAL"
    And I assign "mas_trades_modified_AOI" to variable "PUBLISHING_FILE_NAME_MODIFIED_AOI"
    And I assign "mas_trades_modified_NON_AOI" to variable "PUBLISHING_FILE_NAME_MODIFIED_NON_AOI"

    And I assign "mas_trades_original_master.csv" to variable "MASTER_FILE_NAME_ORIGINAL"
    And I assign "mas_trades_modified_AOI_master.csv" to variable "MASTER_FILE_NAME_MODIFIED_AOI"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/unavista/" to variable "PUBLISHING_DIR"

  Scenario: Prerequisites to cleardown existing data

    When I execute below query to "Clear data for the given trades from ft_t_extr"
    """
    ${testdata.path}/sql/0001_ClearDown.sql
    """

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_DISCARD}_${VAR_SYSDATE}_1.csv          |
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv         |
      | ${PUBLISHING_FILE_NAME_MODIFIED_AOI}_${VAR_SYSDATE}_1.csv     |
      | ${PUBLISHING_FILE_NAME_MODIFIED_NON_AOI}_${VAR_SYSDATE}_1.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_DISCARD}.csv  |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_UV_TREASURY_TRADE_MAS_SUB |
      | AOI_PROCESSING              | true                                 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                 |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_DISCARD}_${VAR_SYSDATE}_1.csv |

  Scenario: Load ISSUER, BROKER and SECURITY files

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_ISSUER_FILENAME}   |
      | ${INPUT_BROKER_FILENAME}   |
      | ${INPUT_SECURITY_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_ISSUER_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_ISSUER        |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_BROKER_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY  |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_SECURITY_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

  Scenario: Load three trades, one of which qualifies as an MAS Trade. One record should get published

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRADE_ORIGINAL} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_TRADE_ORIGINAL}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_TREASURY |

  # Publish the EMIR report file. There should be 1 record in the output file
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_ORIGINAL}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_UV_TREASURY_TRADE_MAS_SUB |
      | AOI_PROCESSING              | true                                 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                 |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv |

    And I capture current time stamp into variable "recon.timestamp"
    And I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv" to variable "ACTUAL_FILE"
    And I assign "${testdata.path}/outfiles/expected/${MASTER_FILE_NAME_ORIGINAL}" to variable "EXPECTED_FILE"
    And I assign "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" to variable "EXCEPTIONS_FILE"

    And I expect reconciliation between generated CSV file "${ACTUAL_FILE}" and reference CSV file "${EXPECTED_FILE}" should be successful and exceptions to be written to "${EXCEPTIONS_FILE}" file

  Scenario: Re-load an existing EMIR Trade with a change to AOI field and Publish EMIR report. Change TRD_ORIG_FACE to 165000000 and Increment TOUCH_COUNT by 1 The record should get published

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRADE_MODIFIED_AOI} |

    # Load another Trade file with a modification to the AOI field. For example:- change TRD_ORIG_FACE to '4000000'
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_TRADE_MODIFIED_AOI}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_TREASURY |

  # Publish the EMIR report file. There should be 1 record in the output file
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_MODIFIED_AOI}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_UV_TREASURY_TRADE_MAS_SUB     |
      | AOI_PROCESSING              | true                                     |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_MODIFIED_AOI}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_MODIFIED_AOI}_${VAR_SYSDATE}_1.csv |

    And I capture current time stamp into variable "recon.timestamp"
    And I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_MODIFIED_AOI}_${VAR_SYSDATE}_1.csv" to variable "ACTUAL_FILE"
    And I assign "${testdata.path}/outfiles/expected/${MASTER_FILE_NAME_MODIFIED_AOI}" to variable "EXPECTED_FILE"
    And I assign "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" to variable "EXCEPTIONS_FILE"

    And I expect reconciliation between generated CSV file "${ACTUAL_FILE}" and reference CSV file "${EXPECTED_FILE}" should be successful and exceptions to be written to "${EXCEPTIONS_FILE}" file

  Scenario: Re-load an existing EMIR Trade with a change to a non-AOI field and Publish EMIR report. Change TRD_SERIES_NUM to 1 and Increment TOUCH_COUNT by 1. The record should NOT get published

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRADE_MODIFIED_NON_AOI} |

    # Step 11:  Load yet another Trade file with a modification to the non-AOI field. For example:- change TRD_SERIES_NUM to '1'
    And I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_TRADE_MODIFIED_NON_AOI}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_TREASURY |

    # Step 12: Publish the EMIR report file. There should be 1 record in the output file
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_MODIFIED_NON_AOI}.csv |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_UV_TREASURY_TRADE_MAS_SUB         |
      | AOI_PROCESSING              | true                                         |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                         |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_MODIFIED_NON_AOI}_${VAR_SYSDATE}_1.csv |




