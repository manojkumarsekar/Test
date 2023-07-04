#https://jira.intranet.asia/browse/TOM-4996

#EISDEV-7303: Added CCURCUR INSTR_TYPE

@gc_interface_cash @gc_interface_portfolios @gc_interface_securities
@dmp_regression_integrationtest
@tom_4996 @tom_5068 @eisdev_7303 @eisdev_7571
Feature: This feature file is to test File365 Cash Collateral (NEWM)

  This feature file is to test below 2 scenarios -
  1. Loading 3 trades, out of which 2 trades satisfies all filter condition should gets published.
  2. 3rd Trade does not satisfy port group = 'TW_BNPPROC' condition and does not gets published.

  Scenario: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CashCollateral" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_TOM_4996.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "PublishedFile_CC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv            |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Clear any residual prod copy trades recaps by running the report once

    Given I assign "PublishedFile_CANC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_C_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Setup new account in DMP

    Given I assign "Portfoliotemplate.xlsx" to variable "PORTFOLIO_FILENAME"

    And I process "${testdata.path}/infiles/${PORTFOLIO_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    And I execute below query
    """
    ${testdata.path}/sql/Insert_ACGP_4996.sql
    """

  Scenario: Setup new account in DMP

    Given I assign "Portfolio_template.out" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BNP_PORTFOLIO  |

  Scenario: Load Fresh data for Trades

    Given I assign "Security_template.out" to variable "INPUT_FILENAME1"
    And I assign "Transaction_template.out" to variable "INPUT_FILENAME2"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "2"
    Then I expect workflow is processed in DMP with success record count as "2"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME2}                   |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"
    Then I expect workflow is processed in DMP with success record count as "4"

  Scenario: Publish File365 Cash Collateral file

    Given I assign "PublishedFile_CC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv            |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'NEWM'
      AND DATA_SRC_ID = 'BNP'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('C873415A','C873415B','F308533BRA') AND  END_TMS IS NULL
      )
     """

  Scenario: Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_CC_REFERENCE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${OUTPUT_FILE}   |
      | ExpectedFile | ${testdata.path}/outfiles/reference/${MASTER_FILE} |

  Scenario: Load Fresh data for Trades

    Given I assign "Security_template_CANC.out" to variable "INPUT_FILENAME1"
    And I assign "Transaction_template_CANC.out" to variable "INPUT_FILENAME2"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME1}  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "2"
    Then I expect workflow is processed in DMP with success record count as "2"

    And I process "${testdata.path}/infiles/${INPUT_FILENAME2}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME2}                   |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"
    Then I expect workflow is processed in DMP with success record count as "4"

  Scenario: Publish File365 Cash Collateral file

    Given I assign "PublishedFile_CANC" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME           | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_C_SUB |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'CANC'
      AND DATA_SRC_ID = 'BNP'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('C873415A','C873415B','C308533BRA') AND  END_TMS IS NULL
      )
     """

  Scenario: Check if published file contains all the records which were loaded for Fundapps Portfolio data

    Given I assign "OUTBOUND_CC_C_REFERENCE.csv" to variable "MASTER_FILE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${OUTPUT_FILE}   |
      | ExpectedFile | ${testdata.path}/outfiles/reference/${MASTER_FILE} |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
