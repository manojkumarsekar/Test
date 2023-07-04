# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 10/04/2019      TOM-5206    Initial Version
# =====================================================================
# https://jira.intranet.asia/browse/TOM-5206

@gc_interface_treasury @gc_interface_issuer @gc_interface_counterparty @gc_interface_securities
@dmp_regression_integrationtest
@tom_5206 @tom_5416 @treasury @emir
Feature: UnaVista EMIR Reporting - LEI Change Requirement

  Test #1: Load a Trade file containing 7 trades.
  Trade 1 has Portfolio = 'GTFXHED' and Counterparty = 'PCHL/PHL/PRUPLC' and Security Type 'CASH/TD'
  Trade 2 has Portfolio = 'GTFXHED' and Counterparty = 'PCHL/PHL/PRUPLC' and Security Type 'FX/FWRD'
  Requirement is to publish respective ReportingCounterparty and beneficiary of  those trades where Portfolio = 'GTFXHED' and Counterparty = 'PCHL/PHL/PRUPLC' and Security Type 'FX/FWRD'

  Scenario: Assign variables

    Given I assign "issuer_5206.xml" to variable "INPUT_ISSUER_FILENAME"
    And I assign "broker_5206.xml" to variable "INPUT_BROKER_FILENAME"
    And I assign "sm_5206.xml" to variable "INPUT_SECURITY_FILENAME"

    And I assign "transaction_original_5206.xml" to variable "INPUT_TRADE_ORIGINAL"

    And I assign "tests/test-data/dmp-interfaces/Treasury/EMIR_Reporting" to variable "testdata.path"
    And I assign "esi_pitl_unavista_emir_trades" to variable "PUBLISHING_FILE_NAME_ORIGINAL"
    And I assign "esi_pitl_unavista_emir_trades.csv" to variable "MASTER_FILE_NAME_ORIGINAL"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/unavista/" to variable "PUBLISHING_DIR"

  Scenario: Prerequisites to cleardown existing data

    When I execute below query to "Clear data for the given trades from ft_t_extr"
    """
    ${testdata.path}/sql/0001_ClearDown.sql
    """

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv  |
      | ${PUBLISHING_FILE_NAME_PRUHL}_${VAR_SYSDATE}_1.csv     |
      | ${PUBLISHING_FILE_NAME_PRUPLCLIQ}_${VAR_SYSDATE}_1.csv |

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

  Scenario: Load two trades, one of which qualifies as an EMIR Trade. One record should get published

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_TRADE_ORIGINAL} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_TRADE_ORIGINAL}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_TREASURY |

  # Publish the EMIR report file. There should be 1 record in the output file
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_ORIGINAL}.csv  |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_UV_TREASURY_TRADE_EMIR_SUB |
      | AOI_PROCESSING              | true                                  |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                  |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv |

    And I capture current time stamp into variable "recon.timestamp"
    And I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_ORIGINAL}_${VAR_SYSDATE}_1.csv" to variable "ACTUAL_FILE"
    And I assign "${testdata.path}/outfiles/expected/${MASTER_FILE_NAME_ORIGINAL}" to variable "EXPECTED_FILE"
    And I assign "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" to variable "EXCEPTIONS_FILE"


    Then I exclude below columns from CSV file while doing reconciliations
      | Reporting Timestamp  |
      | Valuation Timestamp  |
      | Exchange Rate 1      |
      | Mark to Market Value |

    And I expect reconciliation between generated CSV file "${ACTUAL_FILE}" and reference CSV file "${EXPECTED_FILE}" should be successful and exceptions to be written to "${EXCEPTIONS_FILE}" file







