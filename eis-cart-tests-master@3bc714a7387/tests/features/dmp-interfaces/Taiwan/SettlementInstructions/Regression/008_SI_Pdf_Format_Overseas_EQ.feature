#https://jira.intranet.asia/browse/TOM-4084
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+-+Generate+Settlement+Instructions+Outbound+File#MainDeck--930366821

@tom_4085 @taiwan_settlement_instruction @si_overseas_eq_pdfcomparison @si_pdf_format_check
Feature: Load new and Amended Confirmed Trade file in DMP and test SSI report generated for Overseas Equity trades based on requirement
  Settlement Instruction is generated out of DMP for overseas Equity (Equity/Equity) and market !=Taiwan asset type to be used by Middle office in Taiwan.
  This feature file cover all the different scenarios needs to be executed to test confirm trade
  1.The settelement instruction should be generated if the new trade with confirmed status is loaded into DMP
  2.Amendement to the mandatory fields mentioned in the requirement in Trade file will generate settlement instruction

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "006_trade_overseasEQ_confirmed_template.xml" to variable "TRADE_INPUT_TEMPLATENAME"
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "MM/dd/YYYY" and assign to variable "VAR_DATE"
    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIRECTORY"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3536-TEST_OVR_EQ') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3536-TEST_OVR_EQ') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

  Scenario: prerequisite to load File10 for testing SSI Overseas Equity (Equity/Equity) and DESC_INST2 contains ETF report
    Given I assign "overseasEQ_sm_file.xml" to variable "INPUT_FILENAME_EQUITY"
    And I assign "broker.xml" to variable "INPUT_FILENAME_BROKER"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME_PORTFOLIO"
    And I assign "INE111A01025" to variable "ISIN1"
    And I assign "BPM1LQ437" to variable "CUSIP1"

    Then I extract below values from the xml file "${testdata.path}/infiles/prerequisite/${INPUT_FILENAME_EQUITY}"  with xpath or tagName at index 0 and assign to variables:
      | //EQUITY_EQUITY//CUSIP[text()='${CUSIP1}']/../DESC_INSTMT | SECURITY_DESC1 |


    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EQUITY}    |
      | ${INPUT_FILENAME_BROKER}    |
      | ${INPUT_FILENAME_PORTFOLIO} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_EQUITY} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW  |

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
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='2'
      """

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_BROKER} |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY  |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='1'
      """

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

    And I expect value of column "TRD_COUNTERPARTY1" in the below SQL query equals to "1":
     """
     SELECT COUNT(*) AS TRD_COUNTERPARTY1 FROM FT_T_FIDE fide
     inner join FT_T_FIID fiid
     on fide.INST_MNEM=fiid.INST_MNEM
     where fiid.FINS_ID ='DBS-TW'
     and fiid.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
     AND fiid.end_tms IS NULL
     """

    And I expect value of column "ACCOUNT_NAME" in the below SQL query equals to "1":
     """
      SELECT  COUNT(*) AS ACCOUNT_NAME from ft_t_acid acid
      inner join ft_t_acct acct
      on acct.acct_id = acid.acct_id
      inner join ft_t_frap frap
      on acid.acct_id = frap.acct_id
      inner join FT_T_FINS fins
      on frap.inst_mnem = fins.inst_mnem
      inner join ft_t_fiid fiid
      on fins.inst_mnem=fiid.inst_mnem
      where frap.FINSRL_TYP='CUSTDIAN'
      And fiid.FINS_ID_CTXT_TYP='INHOUSE'
      And acid.acct_id_ctxt_typ = 'CRTSID'
      And acid.acct_alt_id ='TSTTT56'
      And acid.end_tms is null
     """


  Scenario Outline: validate SSI report for Overseas EQUITY trade <SSIScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "006_trade_overseasEQ_confirmed_${VAR_RANDOM}.xml" to variable "TRADE_INPUT_FILENAME"

    And I create input file "${TRADE_INPUT_FILENAME}" using template "${TRADE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE       | DateTimeFormat:MM/dd/YYYY |
      | CUSIP            | <Cusip>                   |
      | ISIN             | <Isin>                    |
      | PORTFOLIO        | <TrdPortfolio>            |
      | TOUCH_COUNT      | <TrdTouchCount>           |
      | TRD_CURRENCY     | <TrdCurrency>             |
      | TRD_COUNTERPARTY | <TrdCounterParty>         |
      | TRD_PRICE        | <TrdPrice>                |
      | TRAN_TYPE        | <TranType>                |
      | TRD_COMMISSION   | <TrdCommission>           |
      | TRD_ORIG_FACE    | <TrdOriginalFace>         |
      | TRD_OTHER_FEE    | <TrdOtherFee>             |
      | TRD_PRINCIPAL    | <Trdprincipal>            |
      | TRD_SETTLE_DATE  | <SettleDate>              |
      | TRD_TRADE_DATE   | <TradeDate>               |
      | TRD_INTEREST     | <TrdInterest>             |
      | TRD_COUPON       | <TrdCoupon>               |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${TRADE_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${TRADE_INPUT_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

     # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.GEN_CNT = <TrdTouchCount>
      AND EXST.DATA_SRC_ID = 'BRS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3536-TEST_OVR_EQ' AND  END_TMS IS NULL
      )
      """

    Then I pause for 10 seconds

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |

    Then I execute below query and extract values of "SSI_JOB_ID" into same variables
      """
      SELECT JOB_ID AS SSI_JOB_ID from ft_t_jblg WHERE INSTANCE_ID = '${flowResultId}' AND JOB_CONFIG_TXT='Publish Insight Report Job'
      """

    And I execute below query and extract values of "PDF_FILE_NAME" into same variables
      """
      SELECT TRN_MSG_STAT_DESC AS PDF_FILE_NAME FROM ft_t_trid
      WHERE JOB_ID = '${SSI_JOB_ID}'
      AND CRRNT_TRN_STAT_TYP ='CLOSED'
      """

    #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = '<ReportStatus>'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3536-TEST_OVR_EQ' AND  END_TMS IS NULL
      AND trunc(TRD_DTE) = to_date('<TradeDate>', 'mm/dd/yyyy')
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PDF_FILE_NAME}.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PDF_FILE_NAME}.pdf.error |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PDF_FILE_NAME}.pdf |

    When I load pdf file "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions/outfiles/runtime/${PDF_FILE_NAME}.pdf" for processing
    Then I consider below content to be excluded in pdf comparison with TEXT mode
      | <TextToSkip> |

    Then I expect below pdf files should be identical
      | tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions/outfiles/expected/<ReportName>        |
      | tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions/outfiles/runtime/${PDF_FILE_NAME}.pdf |

    Examples: Trade Parameters
      | SSIScenario                                                | Cusip     | Isin     | TranType | TradeDate   | SettleDate  | TrdPortfolio | TrdOriginalFace | TrdCounterParty | Trdprincipal | TrdPrice | TrdCommission | TrdOtherFee | TrdCurrency | TrdCoupon | TrdInterest | TrdTouchCount | ReportStatus | ReportName                | TextToSkip          |
      | Confirmed New Trade                                        | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE} | TSTTT56      | 1000            | DBS-TW          | 14000        | 14       | 0             | 1.25        | TWD         | 0         | 0           | 1             | NEWSENT      | Equity_New_Trade.pdf      | 2019/05/29 11:05:53 |
      | Updated Confirmed New Trade mandatory field(TrdCommission) | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE} | TSTTT56      | 1000            | DBS-TW          | 14000        | 14       | 100           | 1.25        | TWD         | 0         | 0           | 2             | REVSENT      | Equity_Rev_Commission.pdf | 2019/05/29 11:05:16 |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory