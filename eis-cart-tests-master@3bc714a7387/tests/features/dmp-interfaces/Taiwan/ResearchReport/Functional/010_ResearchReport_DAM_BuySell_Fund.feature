@tom_3876 @dmp_twrr_functional @dmp_tw_functional
Feature: Test Reseacrh Report for TW DAM Buy Sell for Sec Group = FUND

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security
  This feature will test all the scenarios for DAM category as mentioned in the requirement
  Expected Result: Research report workflow will load the DAM report and update order status PM instruction and Int comment

  #  Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "esi_orders_fund_dam.xml" to variable "ORDER_INPUT_TEMPLATENAME"
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

  Scenario Outline: validate research report for TW DAM Buy Sell for Sec Group = FUND and scenario <ReportScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
    And I assign "esi_orders_Dam_Fund_${VAR_RANDOM}.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "${brs.research.report.link}${VAR_RANDOM}" to variable "INTERNAL_LINK"


    And I execute below query
      """
      DELETE from FT_T_RSP1 where trunc(START_TMS)=trunc(SYSDATE);
      DELETE from FT_T_RSR1 where trunc(START_TMS)=trunc(SYSDATE);
      COMMIT
      """

    When I send research report email for category "<CategoryTemplate>" to common mail box with below details
      | PORTFOLIO          | <ReportPortfolio>     |
      | TEMP_PORTFOLIO     | <ReportTempPortfolio> |
      | REPORT_DATE        | ${VAR_DATE}           |
      | CUSIP              | <ReportAssetID>       |
      | TW_Buy_Sell        | <ReportTrnType>       |
      | PRICE              | <Reportprice>         |
      | LINK               | ${VAR_RANDOM}         |
      | Target_Price_Lower | <TargetLowerPrice>    |
      | Target_Price_Upper | <TargetUpperPrice>    |
      | NEW_END_DATE       |                       |

    Then I pause for 5 seconds

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

    #Verify Order details before and after reserach report job triggered and both should matched
    And I expect the value of var "${BASKET_ID_BF}" equals to "${BASKET_ID}"
    And I expect the value of var "${PORTFOLIO_TICKER_BF}" equals to "${PORTFOLIO_TICKER}"
    And I expect the value of var "${QUANTITY_BF}" equals to "${QUANTITY}"
    And I expect the value of var "${TRADE_PURPOSE_BF}" equals to "${TRADE_PURPOSE}"
    And I expect the value of var "${LIMIT_PRICE_BF}" equals to "${LIMIT_PRICE}"
    And I expect the value of var "${MARKET_PRICE_BF}" equals to "${MARKET_PRICE}"
    And I expect the value of var "${ISIN_BF}" equals to "${ISIN}"
    And I expect the value of var "${SEDOL_BF}" equals to "${SEDOL}"
    And I expect the value of var "${ENTRY_TIME_BF}" equals to "${ENTRY_TIME}"
    And I expect the value of var "${ORDER_STATUS_BF}" equals to "${ORDER_STATUS}"

    Examples: Order Parameters
      | CategoryTemplate | ReportScenario                            | TargetLowerPrice | TargetUpperPrice | Reportprice | ReportTrnType | ReportPortfolio | ReportTempPortfolio | ReportAssetID | AssetID   | TranType | BasketID       | PortfolioTicker | Quantity | TradePurpose         | LimitPrice | MarketPrice | IsCompliance | PMInstruction   | IntComment       |
      | DAMTemplate.txt  | MarketPrice*0.95 < TargetLowerPrice(Sell) | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB01FC523     | SB01FC523 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell | 3750       | 13.575      | false        | TWRES_PX_MISMAT | ${INTERNAL_LINK} |
      | DAMTemplate.txt  | MarketPrice*1.05 > TargetUpperPrice(Buy)  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | BRSRWYNJ5     | BRSRWYNJ5 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell | 3750       | 5400        | false        | TWRES_PX_MISMAT | ${INTERNAL_LINK} |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory