#https://jira.intranet.asia/browse/TOM-4084
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+-+Generate+Settlement+Instructions+Outbound+File#MainDeck--930366821

@tom_4085 @taiwan_settlement_instruction @si_dom_eq_confirmedtrade @tom_4470
Feature: Load new Trade file in DMP and test SSI report not generated for domestic EQ trades based on requirement
  Settlement Instruction is not generated out of DMP for domestic Equity (Secgroup: Equity, Market =TW and DESC_INSTMT2 !=ETF) asset type.
  This feature file cover all the different scenarios needs to be executed to test confirm trade
  1.The settelement instruction should not be generated if the new domestic EQ trade with confirmed status is loaded into DMP

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "005_trade_domesticEQ_confirmed_template.xml" to variable "TRADE_INPUT_TEMPLATENAME"
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "MM/dd/YYYY" and assign to variable "VAR_DATE"
    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIRECTORY"

    #get counterparty name and fins details from DMP
    And I execute below query and extract values of "TRD_COUNTERPARTY1" into same variables
     """
     SELECT fiid.FINS_ID AS TRD_COUNTERPARTY1 FROM FT_T_FIDE fide
     inner join FT_T_FIID fiid
     on fide.INST_MNEM=fiid.INST_MNEM
     where fiid.FINS_ID like '%TW'
     and fiid.FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
     AND fiid.end_tms IS NULL
     AND ROWNUM = 1
     """

     # end tms old entry in extr and etid table for same fund and inv number
    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('3536-TEST_DOM_EQ') AND END_TMS IS NULL;
     UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('3536-TEST_DOM_EQ') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
     COMMIT
    """

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

  Scenario: prerequisite to load File10 for testing SSI Domestic equity report
    Given I assign "domesticEQ_sm_file.xml" to variable "INPUT_FILENAME_CIS"
    And I assign "TW0002345006" to variable "ISIN1"
    And I assign "S60052149" to variable "CUSIP1"
    And I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN1}'"
    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN1}'"

    When I copy files below from local folder "${testdata.path}/infiles/prerequisite" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_CIS} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_CIS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    #Check there is no DESC_INST2 value in DMP ISST table
    And I expect value of column "ISST_DESCINSMT2_ROW_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS ISST_DESCINSMT2_ROW_COUNT FROM FT_T_ISST ISST
      WHERE ISST.STAT_DEF_ID = 'DSCINST2'
      AND ISST.END_TMS IS NULL
      AND ISST.INSTR_ID IN (SELECT INSTR_ID FROM ft_t_isid WHERE iss_id ='${CUSIP1}' and END_TMS is null
      )
      """

    #Check Sec Group of is equity
    And I expect value of column "ISCL_EQUITY_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ISCL_EQUITY_ROW_COUNT FROM FT_T_ISCL ISCL
      WHERE ISCL.INDUS_CL_SET_ID = 'SECGROUP'
      AND ISCL.CL_VALUE = 'EQUITY'
      AND ISCL.END_TMS IS NULL
      AND ISCL.INSTR_ID IN (select INSTR_ID from ft_t_isid where iss_id ='${CUSIP1}' and END_TMS is null
      )
      """

    #check security belongs to market taiwan
    And I expect value of column "MKIS_XTAI_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS MKIS_XTAI_ROW_COUNT
      FROM ft_t_mkid mkid, ft_t_mkis mkis, ft_t_mixr mixr
      WHERE  mixr.isid_oid IN ( SELECT ISID_OID FROM ft_t_isid WHERE iss_id ='${CUSIP1}' AND END_TMS is null)
      AND   mixr.mkt_iss_oid = mkis.mkt_iss_oid
      AND   mixr.end_tms is null
      AND   mkis.mkt_oid = mkid.mkt_oid
      AND   mkis.end_tms IS NULL
      AND   mkid.mkt_id_ctxt_typ = 'MIC'
      AND   mkid.MKT_ID IN ('XTAI','ROCO')
      AND   mkid.end_tms is null
      """

  Scenario Outline: validate SSI report for Domestic Equity trade <SSIScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "001_trade_dom_eq_confirmed_${VAR_RANDOM}.xml" to variable "TRADE_INPUT_FILENAME"

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
      WHERE TRD_ID = '3536-TEST_DOM_EQ' AND  END_TMS IS NULL
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
    WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
    AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
    AND EXST.DATA_SRC_ID = 'BRS'
    AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
    WHERE TRD_ID = '3536-TEST_DOM_EQ' AND  END_TMS IS NULL
    )
    """

    Then I expect value of column "PUB_DESC" in the below SQL query equals to "No rows found by the publishing query":
    """
    SELECT PUB_DESCRIPTION AS PUB_DESC from ft_v_pub1
    WHERE SUBSCRIPTION_NME ='EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI'
    AND SBDF_OID IN (select SBDF_OID from FT_CFG_SBDF where SUBSCRIPTION_NME ='EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI')
    order by START_TMS desc
    fetch first 1 row only
    """
    Examples: Trade Parameters
      | SSIScenario         | Cusip     | Isin     | TranType | TradeDate   | SettleDate  | TrdPortfolio      | TrdOriginalFace | TrdCounterParty      | Trdprincipal | TrdPrice | TrdCommission | TrdOtherFee | TrdCurrency | TrdTouchCount |
      | Confirmed New Trade | ${CUSIP1} | ${ISIN1} | BUY      | ${VAR_DATE} | ${VAR_DATE} | ${PORTFOLIO_NAME} | 1000            | ${TRD_COUNTERPARTY1} | 14000        | 14       | 0             | 1.25        | TWD         | 1             |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory