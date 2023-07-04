#https://collaborate.intranet.asia/pages/viewpage.action?pageId=53941317#MainDeck--2066775069

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios
@dmp_regression_integrationtest
@dmp_taiwan @trade_recap_adhoc @trade_recap_ssb_adhoc
@eisdev_4834

Feature: Test Trade Recap Adhoc publishing to SSB

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_SSB_Adhoc.sql
    """

    And I execute below query and extract values of "CURR_DATE" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE from dual
     """

    And I execute below query and extract values of "CURR_DATE_MINUS_1" into same variables
     """
     select to_char(max(GREG_DTE),'MM/DD/YYYY') AS CURR_DATE_MINUS_1 from ft_t_cadp where GREG_DTE < trunc(SYSDATE) and end_tms is null and BUS_DTE_IND = 'Y' and cal_id = 'PRPTUAL'
     """

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template_TOM_3383.xlsx" to variable "PORTFOLIO_FILENAME"

    And I process "${testdata.path}/infiles/${PORTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP1_FRAP_SSB_Adhoc.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "traderecap_ssb_adhoc" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_ADHOC_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                |
      | RUNTIME_CHAR_VAL_TXT        | Test3383                            |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load trade

    Given I assign "0009_tradefile_ssb_adhoc.xml" to variable "INPUT_FILENAME"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    And I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish trade recap file for SSB

    Given I assign "traderecap_ssb_adhoc" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_ADHOC_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                |
      | RUNTIME_CHAR_VAL_TXT        | Test3383                            |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('3204-3204_01') AND  END_TMS IS NULL
      )
      """

  Scenario: Verify trade recap SSB file

    Given I assign "TradeRecapExpected_ssb_adhoc_template.csv" to variable "EXPECTED_FILE_TEMPLATE"
    And I assign "TradeRecapExpected_ssb_adhoc.csv" to variable "EXPECTED_FILE"
    And I create input file "${EXPECTED_FILE}" using template "${EXPECTED_FILE_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      |  |  |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/outfiles/testdata/${EXPECTED_FILE}                            |