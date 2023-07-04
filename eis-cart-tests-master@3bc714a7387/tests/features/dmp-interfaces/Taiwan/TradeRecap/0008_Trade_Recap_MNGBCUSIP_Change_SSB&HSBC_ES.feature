#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--1787168545
#https://jira.intranet.asia/browse/TOM-4815
#https://jira.intranet.asia/browse/TOM-5364 -  Test data changed as part of regression failure fix
#https://jira.intranet.asia/browse/TOM-5072 - Mapping changes for TRD_REG_DATE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-4567 - Mapping Changes for TRD_FIFO_TYPE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-6990 - Refactor feature file to reduce complexity

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan @tom_4815 @trade_recap  @tom_5364 @tom_5072 @eisdev_4567 @eisdev_6990 @eisdev_6990_ssb_hsbc_es
Feature: This feature file is to test Trade Recap data published with MNGBCUSIP identifier for SSB & HSBC (ES).

  Since MnG's instance of Aladdin hold the same unique identifiers (BCUSIP, FUND ID),
  but the values in the identifiers may differ from what in Eastspring instance,
  Hence to establish this different value from MNG,
  new identifier labels - MNGBCUSIP will get set up in DMP

  This feature file is to test below 2 scenarios -
  1. Loading security file and trade coming from MnG instance to check
  whether published file has MNGBCUSIP if BCUSIP is missing in DMP
  2. Loading security file and trade coming from ES instance to link MnG instance, to check
  whether published file has ES BCUSIP if BCUSIP and MNGBCUSIP (both) present in DMP

  This feature file to test above scenarios with SSB & HSBC - ES - trade recap publishing

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_SSB_TOM_4815.sql
    """

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TEST00048153'"

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_FX" into same variables
     """
     select TO_CHAR(sysdate, 'YYYYMMDD') AS CURR_DATE_FX from dual
     """

  Scenario: Clear any residual prod copy trades recaps by running the report once for HSBC - TD

    #Running for SSB Batch 1
    Given I assign "traderecap_ssb" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv  |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                         |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

     #Running for HSBC Batch 1

    Given I assign "traderecap_hsbc" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B1 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

     #waiting intentionally
    And I pause for 20 seconds

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_4815.xlsx" to variable "PORTFOLIO_FILENAME"

    Then I process "${testdata.path}/infiles/${PORTFOLIO_FILENAME}" file with below parameters
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP1_FRAP_SSB_TOM_4815.sql
    """

  Scenario: Loading BCUSIP and trade from ES instance for SSB and HSBC

    Given I assign "sm_ES_TOM_4815.xml" to variable "INPUT_FILENAME_SM"
    And I assign "tradefile_ssb_ES_TOM_4815.xml" to variable "INPUT_FILENAME_TXN"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_SM}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_SM}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_TXN}" file with below parameters
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_TXN}           |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I expect workflow is processed in DMP with total record count as "1"

    #Delete EXST status for trade 4815-4815
    And I execute below query
    """
      DELETE FT_T_EXST WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID IN ('SSB','HSBC')
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4815-4815') AND  END_TMS IS NULL
      );
      COMMIT
    """

  Scenario Outline: Publish trade recap file for <Entity> - ES

    Given I assign "<File_Name>" to variable "<PublishFileVar>"
    And I assign "<Directory>" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${<PublishFileVar>}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${<PublishFileVar>}.csv |
      | SUBSCRIPTION_NAME           | <SubscriptionName>      |
      | EXTRACT_STREETREF_TO_SUBMIT | true                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${<PublishFileVar>}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${<PublishFileVar>}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = '<Entity>'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4815-4815') AND  END_TMS IS NULL
      )
      """

    Examples:
      | Entity | File_Name          | Directory     | SubscriptionName              | PublishFileVar            |
      | SSB    | traderecap_ssb_ES  | /dmp/out/ssb  | EITW_DMP_TO_SSB_TRADEFLOW_B1  | PUBLISHING_FILE_NAME_SSB  |
      | HSBC   | traderecap_hsbc_ES | /dmp/out/hsbc | EITW_DMP_TO_HSBC_TRADEFLOW_B1 | PUBLISHING_FILE_NAME_HSBC |


  Scenario: Verify trade recap SSB file - ES
    Given I assign "TradeRecapExpected_ssb_ES_tom_4815_B1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_ssb_ES_tom_4815_B1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_SSB}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/outfiles/testdata/${EXPECTED_FILE}                                |

  Scenario: Verify trade recap HSBC file - ES

    Given I assign "TradeRecapExpected_hsbc_ES_tom_4815_B1_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_hsbc_ES_tom_4815_B1.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME_HSBC}_${VAR_SYSDATE}_1.csv |
      | File2 | ${testdata.path}/outfiles/testdata/${EXPECTED_FILE}                                 |