#https://jira.intranet.asia/browse/TOM-4422
#https://jira.intranet.asia/browse/TOM-4825
#https://jira.intranet.asia/browse/TOM-4826
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=58887327#businessRequirements-dataRequirement

@gc_interface_cash @gc_interface_securities @gc_interface_portfolios @gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4422 @tw_fx_tarde_file367_cancel @tom_4825 @tw_fx_trade_file367 @tom_4826
Feature: Load BRS FX transaction for hedge portfolio (New, Amend, Cancel) and generate file 367( New Cash)

  The purpose of this requirement is to convert Fx transactions for hedge portfolio into new cash for hedge ration calculation bt portfolio manager
  1. Load new FX transaction on hedge/shareclass portfolio and check file 367 generated
  2. Amend file and check file 367 generated
  3. Cancel FX transaction and check file 367 genarted for cancel trades

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/FXTrades-file367" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "FXSPOT_transaction.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "NewCash_BRS_ExpectedOutput.csv" to variable "OUTPUT_TEMPLATE_NEW"
    And I assign "NewCash_BRS_Cancel_ExpectedOutput.csv" to variable "OUTPUT_TEMPLATE_CANCEL"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIRECTORY"
    And I assign "001_NewCash_BRSFile" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "5/30/2019" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "NC_SETTLE_DATE"
    And I assign "fx_sm_file.xml" to variable "INPUT_FILENAME_FX"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"
    And I assign "BES2PT3D3" to variable "CUSIP1"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${CUSIP1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${CUSIP1}'"

    #Clear old transaction by end tms the previous entry
    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3497-FX_SPOT') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3497-FX_SPOT') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

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

    And I assign "TSTTT16_TWD" to variable "SHARE_PORTFOLIO_NAME"
    And I assign "TSTTT16" to variable "MAIN_PORTFOLIO_NAME"

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

  Scenario Outline: validate File 367(New cash file for BRS) generated from FX trade <Scenario Name>

    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "001_FXSPOT_transaction_New_${VAR_RANDOM}.xml" to variable "INPUT_FILENAME"
    And I assign "001_NewCash_BRS_${VAR_RANDOM}_Output.csv" to variable "OUTPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      | PORTFOLIO        | ${SHARE_PORTFOLIO_NAME} |
      | TRD_ORIG_FACE    | <TrdOriginalFace>       |
      | TRD_TICKER       | TWD                     |
      | TRD_CURRENCY     | USD                     |
      | SM_SEC_TYPE      | SPOT                    |
      | TRD_TRADER       | JIL                     |
      | TRD_TRAN_TYPE1   | TRD                     |
      | TRD_CONFIRMED_BY | LIU                     |
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
    Update ft_t_isid set ISS_ID = 'TWD'
    where INSTR_ID IN (select INSTR_ID from ft_t_isid where ISS_ID ='${CUSIP1}' AND END_TMS is null)
    and ID_CTXT_TYP = 'TICKER';
    COMMIT
    """

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}_${VAR_RANDOM}.csv |
      | SUBSCRIPTION_NAME    | <SubscriptionName>                        |

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
    And I assign "TWHGPL SPOT PROVIDER FX C_HSBCT-TW AUD/USD ${SHARE_PORTFOLIO_NAME} -FX_SPOT" to variable "TRD_COMMENTS"

    And I create input file "${OUTPUT_FILENAME}" using template "<NC_OutPut_Template>" with below codes from location "${testdata.path}/outfiles"
      | LINE1_PORTFOLIO | ${MAIN_PORTFOLIO_NAME} |
      | LINE2_PORTFOLIO | ${MAIN_PORTFOLIO_NAME} |
      | LINE1_AMOUNT    | ${QUANTITY}            |
      | LINE2_AMOUNT    | ${PRINCIPAL}           |
      | LINE1_CCY       | TWD                    |
      | LINE2_CCY       | USD                    |
      | LINE1_CASHTYPE  | CASHIN                 |
      | LINE2_CASHTYPE  | CASHOUT                |
      | SETTLE_DATE     | ${NC_SETTLE_DATE}      |
      | TRADE_DATE      | 20190528               |
      | ESTIMATED       | F                      |

    Then I expect all records in file "${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME}" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_1.csv" with same order and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_RANDOM}_${VAR_SYSDATE}_TC2_exceptions.csv" file

    Examples: Trade Parameters
      | Scenario Name               | TrdOriginalFace | TrdTouchCount | TrdStatus | SubscriptionName                      | NC_OutPut_Template        |
      | Load new Trade 3497-FX_SPOT | 10000           | 1             |           | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM | ${OUTPUT_TEMPLATE_NEW}    |
      | Amend Trade 3497-FX_SPOT    | 20000           | 2             |           | EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM | ${OUTPUT_TEMPLATE_NEW}    |
      | Cancel Trade 3497-FX_SPOT   | 20000           | 3             | C         | EITW_DMP_BRS_CASHTRAN_FILE367_FX_CANC | ${OUTPUT_TEMPLATE_CANCEL} |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
