#https://jira.intranet.asia/browse/TOM-4084
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+-+Generate+Settlement+Instructions+Outbound+File#MainDeck--930366821

@tom_4085 @taiwan_settlement_instruction @si_etf_non_mandatory
Feature: Load new and Amended non Mandatory Executed Trade file in DMP and test SSI report generated for ETF funds based on requirement
  Settlement Instruction is generated out of DMP for different asset type to be used by Middle office/Custodians in Taiwan.
  Settlement Instruction is generated out of DMP for ETF (Equity/Equity and DESC_INST2= contains ETF) asset type to be used by Middle office in Taiwan.
  1.The settelement instruction should be generated if the new trade with executed status/confirmed status is loaded into DMP
  2.Amendment to the Non mandatory fields should not generate settlement instruction

  Scenario: Prerequisite clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "004_trade_etf_confirmed_template.xml" to variable "TRADE_INPUT_TEMPLATENAME"
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "MM/dd/YYYY" and assign to variable "VAR_DATE"
    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIRECTORY"

    #get counterparty name and fins details from DMP
    And I execute below query and extract values of "COUNTERPARTY_NAME1;TRD_COUNTERPARTY1" into same variables
     """
     SELECT fide.INST_NME AS COUNTERPARTY_NAME1,fiid.FINS_ID AS TRD_COUNTERPARTY1 FROM FT_T_FIDE fide
     inner join FT_T_FIID fiid
     on fide.INST_MNEM=fiid.INST_MNEM
     where fiid.FINS_ID like '%TW'
     and fiid.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
     AND fiid.end_tms IS NULL
     AND ROWNUM = 1
     """

     #get counterparty name and fins details from DMP
    And I execute below query and extract values of "COUNTERPARTY_NAME2;TRD_COUNTERPARTY2" into same variables
     """
     ${testdata.path}/sql/Get_Counterparty_Details.sql
     """

    #get custodian, account info deom DMP
    And I execute below query and extract values of "CUSTODIAN_NAME;PORTFOLIO_NAME;ACCOUNT_NAME" into same variables
     """
      ${testdata.path}/sql/Get_Account_Custodian.sql
     """

    # end tms old entry in extr and etid table for same fund and inv number
    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3536-TEST_ETF') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3536-TEST_ETF') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

  Scenario: prerequisite to load File10 for testing SSI ETF (Equity/Equity/ETF) report
    Given I assign "etf_sm_file.xml" to variable "INPUT_FILENAME_ETF"
    And I assign "TW0000050004" to variable "ISIN1"
    And I assign "S66834052" to variable "CUSIP1"

    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_ETF} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_ETF}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='2'
      """

  Scenario Outline: validate SSI report for ETF trade <SSIScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "001_trade_etf_confirmed_nm_${VAR_RANDOM}.xml" to variable "TRADE_INPUT_FILENAME"

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
      WHERE TRD_ID = '3536-TEST_ETF' AND  END_TMS IS NULL
      )
      """

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |

    #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = '<ReportStatus>'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3536-TEST_ETF' AND  END_TMS IS NULL
      )
    """

    Then I expect value of column "PUB_COUNT" in the below SQL query equals to "<Pub_Cnt>":
    """
    SELECT PUB_CNT AS PUB_COUNT from ft_v_pub1
    WHERE SUBSCRIPTION_NME ='EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI'
    AND SBDF_OID IN (select SBDF_OID from FT_CFG_SBDF where SUBSCRIPTION_NME ='EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI')
    AND PUB_DESCRIPTION <Pub_Desc>
    order by START_TMS desc
    fetch first 1 row only
    """

    Examples: Trade Parameters
      | SSIScenario                                              | Cusip     | Isin     | TranType | TradeDate   | SettleDate  | TrdPortfolio      | TrdOriginalFace | TrdCounterParty      | Trdprincipal | TrdPrice | TrdCommission | TrdOtherFee | TrdCurrency | TrdTouchCount | ReportStatus | Pub_Desc                                 | Pub_Cnt |
      | Confirm Trade                                            | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE} | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 14000        | 14       | 0             | 1.25        | TWD         | 1             | NEWSENT      | is null                                  | 1       |
      | Updated confirmed Trade Not mandatory field(Touch Count) | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE} | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 14000        | 14       | 0             | 1.25        | TWD         | 2             | NEWSENT      | ='No rows found by the publishing query' | 0       |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory