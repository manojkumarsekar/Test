#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--1787168545
#https://jira.intranet.asia/browse/TOM-4815
#https://jira.intranet.asia/browse/TOM-5364 -  Test data changed as part of regression failure fix
#https://jira.intranet.asia/browse/TOM-5072 - Mapping changes for TRD_REG_DATE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-4567 - Mapping Changes for TRD_FIFO_TYPE field in HSBC Trade recap outbound file
#https://jira.pruconnect.net/browse/EISDEV-6990 - Refactor feature file to reduce complexity
#https://jira.pruconnect.net/browse/EISDEV-7039 - Date columns mapping change

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities @gc_interface_counterparty
@dmp_regression_integrationtest
@dmp_taiwan @tom_4815 @trade_recap  @tom_5364 @tom_5072 @eisdev_4567 @eisdev_6990 @eisdev_6990_hsbc_td @eisdev_7039
Feature: This feature file is to test Trade Recap data published with MNGBCUSIP identifier for HSBC - TD.

  Since MnG's instance of Aladdin hold the same unique identifiers (BCUSIP, FUND ID),
  but the values in the identifiers may differ from what in Eastspring instance,
  Hence to establish this different value from MNG,
  new identifier labels - MNGBCUSIP will get set up in DMP

  This feature file is to test below 2 scenarios -
  1. Loading security file and trade coming from MnG instance to check
  whether published file has MNGBCUSIP if BCUSIP is missing in DMP
  2. Loading security file and trade coming from ES instance to link MnG instance, to check
  whether published file has ES BCUSIP if BCUSIP and MNGBCUSIP (both) present in DMP

  This feature file to test above scenarios with HSBC - TD trade recap publishing

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

  Scenario: Clear any residual prod copy trades recaps by running the report once for HSBC

      #Running for HSBC TD Batch 1

    Given I assign "traderecap_hsbc" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                 |

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

    #Scenarios to test HSBC TD publishing
  Scenario: Loading BCUSIP and trade from MNG instance for HSBC TD

    Given I assign "tradefile_hsbc_MNG_TD_TOM_4815.xml" to variable "INPUT_FILENAME_TXN"
    And I assign "sm_MNG_TD_TOM_4815.xml" to variable "INPUT_FILENAME_SM"
    And  I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TEST00048153'"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_SM}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_SM}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_MNG |

    Then I expect workflow is processed in DMP with total record count as "1"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_TXN}" file with below parameters
      | BUSINESS_FEED |                                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_TXN}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION_MNG |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Publish trade recap file for HSBC TD - MnG

    Given I assign "traderecap_hsbc_TD_MnG" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                 |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4815-4815_TD') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC TD file - MnG

    Given I assign "traderecap_hsbc_TD_MnG_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "traderecap_hsbc_TD_MnG.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}traderecap_hsbc_TD_MnG.csv" file

  Scenario: Loading BCUSIP and trade from ES instance for HSBC TD

    Given I assign "tradefile_hsbc_ES_TD_TOM_4815.xml" to variable "INPUT_FILENAME_TXN_ES"
    And I assign "sm_ES_TD_TOM_4815.xml" to variable "INPUT_FILENAME_SM_ES"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_SM_ES}" file with below parameters
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_SM_ES} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect workflow is processed in DMP with total record count as "1"

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_TXN_ES}" file with below parameters
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME_TXN_ES}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I expect workflow is processed in DMP with total record count as "1"

    #Delete EXST status for trade 4815-4815_TD
    And I execute below query
    """
      DELETE FT_T_EXST WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID IN ('HSBC')
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4815-4815_TD') AND  END_TMS IS NULL
      );
      COMMIT
    """

  Scenario: Publish trade recap file for HSBC TD - ES

    Given I assign "traderecap_hsbc_TD_ES" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B1_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                 |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4815-4815_TD') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap HSBC TD file - ES

    Given I assign "traderecap_hsbc_TD_ES_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "traderecap_hsbc_TD_ES.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/testdata/${EXPECTED_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}traderecap_hsbc_TD_ES.csv" file