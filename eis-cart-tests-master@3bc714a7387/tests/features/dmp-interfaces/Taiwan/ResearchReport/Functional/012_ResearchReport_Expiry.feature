@tom_3876 @dmp_twrr_functional @dmp_tw_functional
Feature: Test Research Report expiry for all categories

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security
  This feature will test all the scenarios for DEQ category as mentioned in the requirement
  Expected Result: Research report workflow will load the DEQ report and update order status PM instruction as expired

  #  Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "esi_orders_equity_new.xml" to variable "ORDER_INPUT_TEMPLATENAME"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/request.xmlt" to variable "RESEARCHREPORT_WORKFLOW"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "RESEARCH_EXPIRE_WORKFLOW"

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

  Scenario Outline: validate research report expiry for categoty <CategoryTemplate> and scenario <ReportScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
    And I assign "esi_orders_New_Expiry_${VAR_RANDOM}.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "${brs.research.report.link}${VAR_RANDOM}" to variable "INTERNAL_LINK"

    And I execute below query
      """
      DELETE from FT_T_RSP1 where trunc(START_TMS)=trunc(SYSDATE);
      DELETE from FT_T_RSR1 where trunc(START_TMS)=trunc(SYSDATE);
      COMMIT
      """

    And I modify date "${VAR_DATE}" with "+70d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "NEW_2M_DATE"
    And I modify date "${VAR_DATE}" with "+120d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "NEW_4M_DATE"
    And I modify date "${VAR_DATE}" with "+90d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "NEW_EXPIRY_DATE"

    And I modify date "${VAR_DATE}" with "-91d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "REPORT_PAST_3M_DATE"
    And I modify date "${REPORT_PAST_3M_DATE}" with "+60d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "OLD_2M_DATE"
    And I modify date "${REPORT_PAST_3M_DATE}" with "+120d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "OLD_4M_DATE"
    And I modify date "${REPORT_PAST_3M_DATE}" with "+90d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "NEW_PAST_EXPIRY_DATE"

    And I modify date "${VAR_DATE}" with "-144d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "REPORT_PAST_4M_DATE"
    And I modify date "${REPORT_PAST_4M_DATE}" with "+90d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "NEW_PAST_EXPIRY_DATE1"

    And I modify date "${VAR_DATE}" with "-31d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "REPORT_PAST_1M_DATE"
    And I modify date "${REPORT_PAST_1M_DATE}" with "+30d" from source format "YYYY-MM-dd" to destination format "YYYY-MM-dd" and assign to "OLD_1M_DATE"

    When I send research report email for category "<CategoryTemplate>" to common mail box with below details
      | PORTFOLIO          | <ReportPortfolio>     |
      | TEMP_PORTFOLIO     | <ReportTempPortfolio> |
      | REPORT_DATE        | <ReportDate>          |
      | CUSIP              | <ReportAssetID>       |
      | TW_Buy_Sell        | <ReportTrnType>       |
      | PRICE              | <Reportprice>         |
      | LINK               | ${VAR_RANDOM}         |
      | Target_Price_Lower | <TargetLowerPrice>    |
      | Target_Price_Upper | <TargetUpperPrice>    |
      | NEW_END_DATE       | <ReportNewEndDate>    |

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

    #Expire old date Report
    And I process the workflow template file "${RESEARCH_EXPIRE_WORKFLOW}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | eitw_ResearchNote_pkg.expire |

    #Verify report  status as expected
    And I assign "<ReportExpStatus>" to variable "REPORT_STATUS"
    Then I expect value of column "RSR1_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RSR1_RECORD_COUNT FROM ft_t_rsr1 where EXT_STATUS= '${REPORT_STATUS}'
    AND EXT_RSRSH_ID ='${INTERNAL_LINK}'
    """

    #Verify expiry date as expected
    And I assign "<ReportExpiryDate>" to variable "REPORT_EXPIRY_DATE"
    Then I expect value of column "RSR1_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RSR1_RECORD_COUNT FROM ft_t_rsr1 where EXT_RSRSH_EXPIRY_DTE = TO_DATE('${REPORT_EXPIRY_DATE}','yyyy-mm-dd')
    AND EXT_RSRSH_ID ='${INTERNAL_LINK}'
    """

     #run reserach report and update BRS order
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    Then I pause for 5 seconds

    #Verify Data and check PM -Instruction and Internal comments updated
    And I retrieve below order details for order number "${ORDER_NUMBER}" and assign into same variables
      | PM_INSTRUCTION   | pmInstruction |
      | INTERNAL_COMMENT | commentValue  |


    And I expect the value of var "${PM_INSTRUCTION}" equals to "<PMInstruction>"
    And I expect the value of var "${INTERNAL_COMMENT}" equals to "<IntComment>"

    Examples: Order Parameters
      | CategoryTemplate       | ReportScenario                                              | TargetLowerPrice | TargetUpperPrice | Reportprice | ReportTrnType | ReportPortfolio | ReportTempPortfolio | ReportAssetID | ReportDate             | ReportNewEndDate | ReportExpiryDate         | ReportExpStatus | AssetID   | TranType | BasketID       | PortfolioTicker | Quantity | TradePurpose                  | LimitPrice | MarketPrice | IsCompliance | PMInstruction | IntComment       |
      | DEQTemplate.txt        | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | DEQTemplate.txt        | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today,New end date= ReportDate + 70days          | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_2M_DATE}   | ${NEW_2M_DATE}           | ACTIVE          | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today,New end date= ReportDate + 120days         | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${VAR_DATE}            | ${NEW_4M_DATE}   | ${NEW_EXPIRY_DATE}       | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 70days  | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_2M_DATE}   | ${OLD_2M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today-91 days,New end date= ReportDate + 120days | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} | ${OLD_4M_DATE}   | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today-91 days,New end date=blank                 | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_3M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE}  | ACTIVE          | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today-144 days,New end date=blank                | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_4M_DATE} |                  | ${NEW_PAST_EXPIRY_DATE1} | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | ReportDate=Today-31 days,New end date=ReportDate +30days    | 2345             | 5150             | 3750        | Sell          | TSTTT16         | TT16                | SB1VJS642     | ${REPORT_PAST_1M_DATE} | ${OLD_1M_DATE}   | ${OLD_1M_DATE}           | TWRES_EXPIRED   | SB1VJS642 | SELL     | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TWRES_EXPIRED | ${INTERNAL_LINK} |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory