#https://jira.intranet.asia/browse/TOM-4422
#https://jira.intranet.asia/browse/TOM-4825
#https://jira.intranet.asia/browse/TOM-4826
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887327#businessRequirements-dataRequirement


@gc_interface_cash @gc_interface_securities @gc_interface_portfolios @gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4422 @tw_fxfwrd_shareclass_mainportfolio_file367 @tom_4825 @tw_fx_trade_file367 @tom_4826
Feature: Load BRS FX FWRD transaction for hedge portfolio and generate file 367( New Cash)
  The purpose of this requirement is to convert Fx transactions for hedge portfolio into new cash for hedge ration calculation bt portfolio manager
  1. Load FX transaction on hedge/shareclass portfolio
  2. Generate file 367(new cash) for hedge ration calculation for BRS
  3. Validate file 367 as per requirement

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/FXTrades-file367" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "FXSPOT_transaction.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "NewCash_BRS_ExpectedOutput.csv" to variable "OUTPUT_TEMPLATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "001_NewCash_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "5/30/2019" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "NC_SETTLE_DATE"
    And I assign "fx_fwrd_sm_file.xml" to variable "INPUT_FILENAME_FX"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"
    And I assign "BES2PT3D3" to variable "CUSIP1"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_FX}        |
      | ${INPUT_FILENAME_PORTFOLIO} |

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

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='8'
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

  Scenario Outline: validate File 367(New cash file for BRS) generated from FX FWRD trade <Scenario Name>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "001_FXFwrd_transaction_New_${VAR_RANDOM}.xml" to variable "INPUT_FILENAME"
    And I assign "001_NewCash_BRS_${VAR_RANDOM}_Output.csv" to variable "OUTPUT_FILENAME"

    #End TMS existing trades to avoid load error
    And I execute below query
    """
    UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3497-FX_SPOT') AND END_TMS IS NULL;
    UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3497-FX_SPOT') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      | PORTFOLIO        | ${SHARE_PORTFOLIO_NAME} |
      | TRD_ORIG_FACE    | <TrdOriginalFace>       |
      | TRD_TICKER       | <TrdTicker>             |
      | TRD_CURRENCY     | <TrdCurrency>           |
      | SM_SEC_TYPE      | <TrdSecType>            |
      | TRD_TRADER       | JIL                     |
      | TRD_TRAN_TYPE1   | TRD                     |
      | TRD_CONFIRMED_BY | <TrdConfirmedBy>        |
      | TOUCH_COUNT      | <TrdTouchCount>         |
      | TRD_STATUS       | <TrdStatus>             |


    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    #Update ticker value in ISID instead of loading new security for ticker
    And I execute below query
    """
    Update ft_t_isid set ISS_ID = '<TrdTicker>'
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where ISS_ID ='${CUSIP1}' AND END_TMS is null)
    and ID_CTXT_TYP = 'TICKER';
    COMMIT
    """

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${VAR_RANDOM}.csv |
      | SUBSCRIPTION_NAME    | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM     |

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_1.csv |

    #Convert the values in desired format
    And I execute below query and extract values of "QUANTITY;COUPON;PRINCIPAL" into same variables
     """
    SELECT TRIM(TO_CHAR(ABS(<TrdOriginalFace>))) AS QUANTITY,
    TRIM(TO_CHAR(ABS('1.4513323799'))) AS COUPON,
    TRIM(TO_CHAR(ABS('66545.6800000000'), '99999.99')) AS PRINCIPAL
    FROM dual
    """

     #Generate comments as per requrement to check in outbound file
    And I assign "TWHGPL <TrdSecType> PROVIDER FX C_HSBCT-TW AUD/USD ${SHARE_PORTFOLIO_NAME} -FX_SPOT" to variable "TRD_COMMENTS"

    And I create input file "${OUTPUT_FILENAME}" using template "${OUTPUT_TEMPLATE}" with below codes from location "${testdata.path}/outfiles"
      | LINE1_PORTFOLIO | <NC2_Portfolio>   |
      | LINE2_PORTFOLIO | <NC1_Portfolio>   |
      | LINE1_AMOUNT    | ${QUANTITY}       |
      | LINE2_AMOUNT    | ${PRINCIPAL}      |
      | LINE1_CCY       | <TrdTicker>       |
      | LINE2_CCY       | <TrdCurrency>     |
      | LINE1_CASHTYPE  | <NC1_CashType>    |
      | LINE2_CASHTYPE  | <NC2_CashType>    |
      | SETTLE_DATE     | ${NC_SETTLE_DATE} |
      | TRADE_DATE      | <NC_TradeDate>    |
      | ESTIMATED       | <NC_ConfirmedBy>  |

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_TC1_exceptions.csv" file


    Examples: Trade Parameters
      | Scenario Name                                                          | TrdOriginalFace | TrdTicker | TrdCurrency | TrdSecType | TrdConfirmedBy | TrdTouchCount | TrdStatus | NC1_Portfolio           | NC2_Portfolio           | NC1_CashType | NC2_CashType | NC_TradeDate | NC_ConfirmedBy |
      | Load buy fx/fwrd(AUD/USD) trade without confirmedBy and check new cash | 10000           | AUD       | USD         | FWRD       |                | 1             |           | ${SPLIT_PORTFOLIO_NAME} | ${SPLIT_PORTFOLIO_NAME} | CASHIN       | CASHOUT      | 20190530     | E              |
      | Load SELL fx/fwrd(AUD/USD) trade with confirmedBy and check new cash   | -10000          | AUD       | USD         | FWRD       | JIL            | 1             |           | ${SPLIT_PORTFOLIO_NAME} | ${SPLIT_PORTFOLIO_NAME} | CASHOUT      | CASHIN       | 20190530     | F              |
      | Load buy fx/fwrd(TWD/USD) trade with confirmedBy and check new cash    | 10000           | TWD       | USD         | FWRD       | JIL            | 1             |           | ${SPLIT_PORTFOLIO_NAME} | ${MAIN_PORTFOLIO_NAME}  | CASHIN       | CASHOUT      | 20190530     | F              |
      | Load Sell fx/fwrd(AUD/TWD) trade with confirmedBy and check new cash   | -10000          | AUD       | TWD         | FWRD       | JIL            | 1             |           | ${MAIN_PORTFOLIO_NAME}  | ${SPLIT_PORTFOLIO_NAME} | CASHOUT      | CASHIN       | 20190530     | F              |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
