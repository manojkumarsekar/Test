@tom_3876 @dmp_twrr_functional @dmp_tw_functional
Feature: Test Reseacrh Report workflow for existing report and check new order get updated

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security
  Research report workflow will update new order status PM instruction and Int comment provide report already present in DMP

  #  Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "esi_orders_equity_new.xml" to variable "ORDER_INPUT_TEMPLATENAME"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" to variable "RESEARCHREPORT_WORKFLOW"

    And I copy files below from local folder "${testdata.path}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_TEMPLATE} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_TEMPLATE}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

    #Pre-requisite : Insert row into ACGP for TW fund group ESI_TW_PROD
    And I execute below query
    """
    ${testdata.path}/sql/InsertIntoACGPTable.sql
    """

  Scenario Outline: Verify new brs order get updated based on existing research report and scenario <ReportScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
    And I assign "esi_orders_New_Deq_${VAR_RANDOM}.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "${brs.research.report.link}${VAR_RANDOM}" to variable "INTERNAL_LINK"

    And I execute below query
      """
      DELETE from FT_T_RSP1 where trunc(START_TMS)=trunc(SYSDATE);
      DELETE from FT_T_RSR1 where trunc(START_TMS)=trunc(SYSDATE);
      COMMIT
      """

    And I execute below query
      """
      Insert into FT_T_RSR1 (RSR1_OID,EXT_RSRSH_ID,EXT_RSRSH_PUB_TMS,DATA_SRC_ID,START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,EXT_STATUS,EXT_RSRSH_CAT,INSTR_ID,EXT_LAST_PRC,EXT_TRGT_PRC_UPPER,EXT_TRGT_PRC_LOWER,TRN_CDE,EXT_RSRSH_EXPIRY_DTE) values ('?571031235','https://ppmg.blackrock.com/aladdinresearch/index.html#/link/${VAR_RANDOM}',to_date(SYSDATE,'DD/MM/RR HH12:MI:SS'),'BRS',to_date(SYSDATE,'DD/MM/RR HH12:MI:SS'),null,to_date(SYSDATE,'DD/MM/RR HH12:MI:SS'),'EITW_BRS_DMP_RESEARCH_REPORT','ACTIVE','TW_DEQ_BS','vT9806wvO1',3750,5150,2345,'BUY',to_date(SYSDATE +2 ,'DD/MM/RR HH12:MI:SS'));
      COMMIT
      """

    And I Post Order using BRS API with below details
      | ASSET_ID          | <AssetID>         |
      | ORDER_TRAN_TYPE   | <TranType>        |
      | BASKET_ID         | <BasketID>        |
      | PORTFOLIO_TICKER  | <PortfolioTicker> |
      | QUANTITY          | <Quantity>        |
      | TRADE_PURPOSE     | <TradePurpose>    |
      | LIMIT_PRICE       | <LimitPrice>      |
      | MARKET_PRICE      | <MarketPrice>     |
      | PM_INITIALS       |                   |
      | IS_RUN_COMPLIANCE | <IsCompliance>    |

    And I assign "${brs.api.order.number}" to variable "ORDER_NUMBER"

    And I retrieve below order details for order number "${ORDER_NUMBER}" and assign into same variables
      | BASKET_ID_BF        | basketId             |
      | PORTFOLIO_TICKER_BF | portfolioTicker      |
      | QUANTITY_BF         | quantity             |
      | TRADE_PURPOSE_BF    | tradePurpose         |
      | LIMIT_PRICE_BF      | limitValue           |
      | MARKET_PRICE_BF     | mktPrice             |
      | PM_INSTRUCTION_BF   | pmInstruction        |
      | ISIN_BF             | isin                 |
      | SEDOL_BF            | sedol                |
      | ENTRY_TIME_BF       | orderDate            |
      | MODIFIED_TIME_BF    | modifiedTimestampUtc |
      | INTERNAL_COMMENT_BF | commentValue         |
      | ORDER_STATUS_BF     | orderStatus          |

    And I create input file "${ORDER_INPUT_FILENAME}" using template "${ORDER_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE    | DateTimeFormat:MM/dd/YYYY |
      | CUSIP         | <AssetID>                 |
      | PORTFOLIO     | <PortfolioTicker>         |
      | QUANTITY      | ${QUANTITY_BF}            |
      | LIMIT_PRICE   | ${LIMIT_PRICE_BF}         |
      | BASKET        | <BasketID>                |
      | ORDERNUMBER   | ${brs.api.order.number}   |
      | MARKETPRICE   | ${MARKET_PRICE_BF}        |
      | TRANTYPE      | <TranType>                |
      | TRADE_PURPOSE | ${TRADE_PURPOSE_BF}       |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_INPUT_FILENAME} |

    And I process the workflow template file "${ORDER_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_ORDERS                           |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                     |
      | EMAIL_TO                | testautomation@eastspring.com               |
      | EMAIL_SUBJECT           | SANITY TEST PUBLISH ORDERS                  |
      | PUBLISH_LOAD_SUMMARY    | true                                        |
      | SUCCESS_ACTION          | DELETE                                      |
      | FILE_PATTERN            | ${ORDER_INPUT_FILENAME}                     |
      | POST_EVENT_NAME         | EIS_UpdateInactiveOrder                     |
      | ATTACHMENT_FILENAME     | Exceptions.xlsx                             |
      | HEADER                  | Please see the summary of the load below    |
      | FOOTER                  | DMP Team, Please do not reply to this mail. |
      | FILE_LOAD_EVENT         | StandardFileLoad                            |
      | EXCEPTION_DETAILS_COUNT | 10                                          |
      | NOOFFILESINPARALLEL     | 1                                           |


    #Verify Order data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN('${ORDER_NUMBER}')
    AND AOST.ORDER_STAT_TYP = 'OPEN'
    """

    #Load reserach report and update BRS order
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    Then I pause for 5 seconds

    #Verify Data and check PM -Instruction and Internal comments updated
    And I retrieve below order details for order number "${ORDER_NUMBER}" and assign into same variables
      | BASKET_ID        | basketId             |
      | PORTFOLIO_TICKER | portfolioTicker      |
      | QUANTITY         | quantity             |
      | TRADE_PURPOSE    | tradePurpose         |
      | LIMIT_PRICE      | limitValue           |
      | MARKET_PRICE     | mktPrice             |
      | PM_INSTRUCTION   | pmInstruction        |
      | ISIN             | isin                 |
      | SEDOL            | sedol                |
      | ENTRY_TIME       | orderDate            |
      | MODIFIED_TIME    | modifiedTimestampUtc |
      | INTERNAL_COMMENT | commentValue         |
      | ORDER_STATUS     | orderStatus          |

    And I expect the value of var "${PM_INSTRUCTION}" equals to "<PMInstruction>"
    And I expect the value of var "${INTERNAL_COMMENT}" equals to "<IntComment>"


    Examples: Order Parameters
      | CategoryTemplate | ReportScenario      | AssetID   | TranType | BasketID       | PortfolioTicker | Quantity | TradePurpose         | LimitPrice | MarketPrice | IsCompliance | PMInstruction   | IntComment       |
      | DEQTemplate.txt  | Report tagged (Buy) | BPM1Q4WV8 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell | 3750       | 200         | false        | TWRES_FD_MISMAT | ${INTERNAL_LINK} |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory