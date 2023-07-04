#https://jira.intranet.asia/browse/TOM-4422
#https://jira.intranet.asia/browse/TOM-4825
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887327#businessRequirements-dataRequirement

@gc_interface_cash @gc_interface_securities @gc_interface_portfolios @gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4825 @tw_fxfwrd_shareclass_mainportfolio_file367 @tw_fx_trade_file367
Feature: Load BRS FX FWRD transaction for hedge portfolio and generate file 367( New Cash)

  The purpose of this requirement is to convert fx transactions for hedge portfolio into new cash for hedge ration calculation bt portfolio manager

  1. Load FX transaction on hedge/shareclass portfolio
  2. Generate file 367(new cash) for hedge ration calculation for BRS
  3. Validate whether currency and portfolio fields are populated as per requirement in file 367
  4. Load FX transaction on hedge/shareclass for non processed portfolio
  5. Verify that no file 367 is generated for non processed portfolio

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/FXTrades-file367" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "tradefile_hsbc_FX_TOM_4825.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "NewCash_BRS_ExpectedOutput.csv" to variable "OUTPUT_TEMPLATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "4825_NewCash_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "5/30/2019" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "NC_SETTLE_DATE"
    And I assign "fx_fwrd_sm_file.xml" to variable "INPUT_FILENAME_FX"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"
    And I assign "PortfolioTemplate_4825.xlsx" to variable "INPUT_FILENAME_PORTFOLIO_NON_PROCESSED"
    And I assign "BES2PT3D3" to variable "CUSIP1"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP1}'"

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_TOM_4825.sql
    """

  Scenario: Clear any residual prod copy trades recaps by running the report once

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

  Scenario: Load data for security, portfolio and trade

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_FX}        |
      | ${INPUT_FILENAME_PORTFOLIO} |
      | ${INPUT_TEMPLATE_FILENAME}  |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_FX}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
    """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_PORTFOLIO}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='8'
    """

    And I assign "TSTTT56_TWD" to variable "SHARE_PORTFOLIO_NAME"
    And I assign "TSTTT56" to variable "MAIN_PORTFOLIO_NAME"
    And I assign "TSTTT56_S" to variable "SPLIT_PORTFOLIO_NAME"

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

    #Pre-requisite : Insert BRSFUNDID in acid table for shareclass
    And I execute below query
    """
    ${testdata.path}/sql/Insert_BrsFundId.sql
    """

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_TEMPLATE_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID3}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
    """

  Scenario: Publish file 367 (Cash)

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM |

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'NEWM' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'BRS'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4825-4825') AND  END_TMS IS NULL
      )
    """

  Scenario: Verify file 367 generated

    Then I expect each record in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" should exist in file "${testdata.path}/outfiles/template/4825_NewCash_BRSFile_expected.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_4825_NewCash_BRSFile_expected.csv.csv" file