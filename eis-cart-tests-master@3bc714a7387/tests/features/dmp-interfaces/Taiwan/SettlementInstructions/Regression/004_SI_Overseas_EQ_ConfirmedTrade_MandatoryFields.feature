#https://jira.intranet.asia/browse/TOM-4084
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+-+Generate+Settlement+Instructions+Outbound+File#MainDeck--930366821

@tom_4085 @taiwan_settlement_instruction @si_overseas_eq_confirmedtrade @tom_4608 @dmp_gs_upgrade
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
    And I modify date "${VAR_DATE}" with "-3d" from source format "MM/dd/YYYY" to destination format "MM/dd/YYYY" and assign to "VAR_DATE1"
    And I modify date "${VAR_DATE}" with "+120d" from source format "MM/dd/YYYY" to destination format "MM/dd/YYYY" and assign to "VAR_DATE2"
    And I modify date "${VAR_DATE}" with "-0d" from source format "MM/dd/YYYY" to destination format "YYYY/MM/dd" and assign to "REPORT_DATE"
    And I modify date "${VAR_DATE1}" with "-0d" from source format "MM/dd/YYYY" to destination format "YYYY/MM/dd" and assign to "REPORT_TRADE_DATE"
    And I modify date "${VAR_DATE2}" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYY/MM/dd" and assign to "REPORT_SETTLE_DATE"

    #get counterparty name and fins details from DMP
    When I assign "1" to variable "RN"
    And I execute below query and extract values of "COUNTERPARTY_NAME1;TRD_COUNTERPARTY1" into same variables
     """
     ${testdata.path}/sql/Get_Counterparty_Details.sql
     """

     #get counterparty name and fins details from DMP
    When I assign "2" to variable "RN"
    And I execute below query and extract values of "COUNTERPARTY_NAME2;TRD_COUNTERPARTY2" into same variables
     """
     ${testdata.path}/sql/Get_Counterparty_Details.sql
     """

    #get custodian, account info deom DMP
    And I execute below query and extract values of "CUSTODIAN_NAME;PORTFOLIO_NAME;ACCOUNT_NAME" into same variables
     """
      ${testdata.path}/sql/Get_Account_Custodian.sql
     """

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3536-TEST_OVR_EQ') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3536-TEST_OVR_EQ') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

  Scenario: prerequisite to load File10 for testing SSI Overseas Equity (Equity/Equity) and DESC_INST2 contains ETF report
    Given I assign "overseasEQ_sm_file.xml" to variable "INPUT_FILENAME_EQUITY"
    And I assign "INE111A01025" to variable "ISIN1"
    And I assign "BPM1LQ437" to variable "CUSIP1"

    Then I extract below values from the xml file "${testdata.path}/infiles/prerequisite/${INPUT_FILENAME_EQUITY}"  with xpath or tagName at index 0 and assign to variables:
      | //EQUITY_EQUITY//CUSIP[text()='${CUSIP1}']/../DESC_INSTMT | SECURITY_DESC1 |

    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_EQUITY} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                          |
      | FILE_PATTERN  | ${INPUT_FILENAME_EQUITY} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW  |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    And I expect value of column "ISST_DESCINSMT2_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ISST_DESCINSMT2_ROW_COUNT FROM FT_T_ISST ISST
      WHERE ISST.STAT_DEF_ID = 'DSCINST2'
      AND ISST.END_TMS IS NULL
      AND ISST.INSTR_ID IN (SELECT INSTR_ID FROM ft_t_isid WHERE iss_id ='${CUSIP1}' and END_TMS is null
      )
      """

    And I expect value of column "ISCL_EQUITY_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISCL_EQUITY_ROW_COUNT FROM FT_T_ISCL ISCL
      WHERE ISCL.INDUS_CL_SET_ID = 'SECGROUP'
      AND ISCL.CL_VALUE = 'EQUITY'
      AND ISCL.END_TMS IS NULL
      AND ISCL.INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id ='${CUSIP1}' and END_TMS is null
      )
      """

    And I expect value of column "MKIS_XTAI_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS MKIS_XTAI_ROW_COUNT
      FROM ft_t_mkid mkid, ft_t_mkis mkis, ft_t_mixr mixr
      WHERE  mixr.isid_oid IN ( SELECT ISID_OID FROM ft_t_isid WHERE iss_id ='${CUSIP1}' AND END_TMS is null)
      AND   mixr.mkt_iss_oid = mkis.mkt_iss_oid
      AND   mixr.end_tms is null
      AND   mkis.mkt_oid = mkid.mkt_oid
      AND   mkis.end_tms IS NULL
      AND   mkid.mkt_id_ctxt_typ = 'MIC'
      AND   mkid.MKT_ID in ('XTAI','ROCO')
      AND   mkid.end_tms is null
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

    #Verify in TRCP for counterparty record creation
    And I expect value of column "TRCP_COUNT" in the below SQL query equals to "1":
      """
      SELECT Count(*) AS TRCP_COUNT FROM FT_t_TRCP
      WHERE EXEC_TRD_ID IN (SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3536-TEST_ETF' AND  END_TMS IS NULL
      AND trunc(TRD_DTE) = to_date('<TradeDate>', 'mm/dd/yyyy')
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

    And I execute below query and extract values of "QUANTITY;PRINCIPAL;PRICE;COMMISSION;OTHERFEE;NETMONEY" into same variables
     """
     SELECT TRIM(TO_CHAR(ABS(<TrdOriginalFace>), '99,999.9999')) AS QUANTITY,
     TRIM(TO_CHAR(ABS(<Trdprincipal>), '99,999.99')) AS PRINCIPAL,
     TRIM(TO_CHAR(<TrdPrice>, '99,999.9999')) AS PRICE ,
     TRIM(TO_CHAR(<TrdCommission>, '99,999.99')) AS COMMISSION ,
     TRIM(TO_CHAR(<TrdOtherFee>, '99,999.99')) AS OTHERFEE ,
     TRIM(TO_CHAR(ABS(<ReportNetMoney>), '99,999.99')) AS NETMONEY
     FROM dual
     """

    Then I expect pdf file should contains below values
      | file:tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions/outfiles/expected/compare_common_variables_report.csv |

    Then I expect pdf file should contains below values
      | Equity Settlement Instructions |
      | <ReportCopy>                   |
#      | Broker:<ReportCounterpartyName>                        |
      | Country:INDIA                  |
      | Currency:<TrdCurrency>         |
      | Exchange:XNSE                  |
      | <ReportTradeDate>              |
      | <ReportSettleDate>             |
      | 3536-TEST                      |
      | <TranType>                     |
      | <ReportSecurityName>           |
      | CONCOR                         |
      | <Isin>                         |
      | BG0ZVG9                        |
      | Test Equity Bank Name          |
      | TRADING BKR BIC: MLILGB3LESF   |
      | DELHI,INDIA                    |
      | PSET: MGTCBEBEECL              |
      | AC-123456                      |
      | Equity Account Name            |
      | CLEARING AGT BIC: MGTCBEBEECL  |
      | EUROCLEAR #: 92835             |
      | DECU/RECU BIC: MGTCBEBEECL     |

    Examples: Trade Parameters
      | SSIScenario                                                  | Cusip     | Isin     | TranType | TradeDate   | SettleDate   | TrdPortfolio      | TrdOriginalFace | TrdCounterParty      | Trdprincipal | TrdPrice | TrdCommission | TrdOtherFee | TrdCurrency | TrdCoupon | TrdInterest | TrdTouchCount | ReportStatus | ReportCopy   | ReportTradeDate | ReportSettleDate      | ReportNetMoney | ReportCounterpartyName | ReportSecurityName |
      | Confirmed New Trade                                          | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 14000        | 14       | 0             | 1.25        | TWD         | 0         | 0           | 1             | NEWSENT      |              | ${REPORT_DATE}  | ${REPORT_DATE}        | 14001.25       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdCommission)   | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 14000        | 14       | 100           | 1.25        | TWD         | 0         | 0           | 2             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 14101.25       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TranType)        | ${CUSIP1} | ${ISIN1} | SELL     | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | -1000           | ${TRD_COUNTERPARTY1} | -14000       | 14       | 100           | 1.25        | TWD         | 0         | 0           | 3             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 13898.75       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(Trdprincipal)    | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 16000        | 14       | 100           | 1.25        | TWD         | 0         | 0           | 4             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 16101.25       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdOriginalFace) | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 14       | 100           | 1.25        | TWD         | 0         | 0           | 5             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 16101.25       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdPrice)        | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.25        | TWD         | 0         | 0           | 6             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 16101.25       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdOtherFee)     | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | TWD         | 0         | 0           | 7             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 16101.50       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdCurrency)     | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE}  | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | USD         | 0         | 0           | 8             | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_DATE}        | 16101.50       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
#      | Updated Confirmed New Trade mandatory field(TradeDate)       | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE1} | ${VAR_DATE}    | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | USD         | 0         | 0           | 9             | NEWSENT      |              | ${REPORT_TRADE_DATE} | ${REPORT_DATE}        | 16101.50       | ${COUNTERPARTY_NAME1}   | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(SettleDate)      | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE2} | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | USD         | 0         | 0           | 10            | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_SETTLE_DATE} | 16101.50       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(Trade Coupon)    | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE2} | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | USD         | 2         | 0           | 11            | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_SETTLE_DATE} | 16101.50       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(Trade Interest)  | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE2} | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY1} | 16000        | 15       | 100           | 1.50        | USD         | 2         | 100         | 12            | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_SETTLE_DATE} | 16101.50       | ${COUNTERPARTY_NAME1}  | ${SECURITY_DESC1}  |
      | Updated Confirmed New Trade mandatory field(TrdCounterParty) | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE2} | ${PORTFOLIO_NAME} | 2000            | ${TRD_COUNTERPARTY2} | 16000        | 15       | 100           | 1.50        | USD         | 2         | 100         | 13            | REVSENT      | REVISED COPY | ${REPORT_DATE}  | ${REPORT_SETTLE_DATE} | 16101.50       | ${COUNTERPARTY_NAME2}  | ${SECURITY_DESC1}  |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory