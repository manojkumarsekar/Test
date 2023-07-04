@tom_3876 @dmp_twrr_functional @dmp_tw_functional
Feature: Research Report tagged orders are not picked by DMP to update again for all categories

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security
  This feature will test all the scenarios for DEQ category as mentioned in the requirement
  Expected Result: Research report workflow will not update the research tagged orders

  #  Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
    And I assign "esi_orders_equity_new.xml" to variable "ORDER_INPUT_TEMPLATENAME"
    And I assign "esi_orders_Equity_Updated.xml" to variable "ORDER_UPDATED_TEMPLATENAME"
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

  Scenario Outline: Research report workflow will not update tagged orders for <CategoryTemplate> and scenario <ReportScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
    And I assign "esi_orders_tagged_${VAR_RANDOM}.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "${brs.research.report.link}${VAR_RANDOM}" to variable "INTERNAL_LINK"
    And I assign "esi_orders_tagged_updated_${VAR_RANDOM}.xml" to variable "ORDER_UPDATED_FILENAME"

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
      | QUANTITY_BF      | quantity     |
      | TRADE_PURPOSE_BF | tradePurpose |
      | LIMIT_PRICE_BF   | limitValue   |
      | MARKET_PRICE_BF  | mktPrice     |
      | ORDER_STATUS_BF  | orderStatus  |

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
      | QUANTITY_AF      | quantity      |
      | TRADE_PURPOSE_AF | tradePurpose  |
      | LIMIT_PRICE_AF   | limitValue    |
      | MARKET_PRICE_AF  | mktPrice      |
      | PM_INSTRUCTION   | pmInstruction |
      | INTERNAL_COMMENT | commentValue  |
      | ORDER_STATUS_AF  | orderStatus   |

    And I expect the value of var "${PM_INSTRUCTION}" equals to "<PMInstruction>"
    And I expect the value of var "${INTERNAL_COMMENT}" equals to "<IntComment>"

    And I create input file "${ORDER_UPDATED_FILENAME}" using template "${ORDER_UPDATED_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE    | DateTimeFormat:MM/dd/YYYY |
      | CUSIP         | <AssetID>                 |
      | PORTFOLIO     | <PortfolioTicker>         |
      | QUANTITY      | ${QUANTITY_AF}            |
      | LIMIT_PRICE   | ${LIMIT_PRICE_AF}         |
      | BASKET        | <BasketID>                |
      | ORDERNUMBER   | ${brs.api.order.number}   |
      | MARKETPRICE   | ${MARKET_PRICE_AF}        |
      | TRANTYPE      | <TranType>                |
      | TRADE_PURPOSE | ${TRADE_PURPOSE_AF}       |
      | INT_COMM      | ${INTERNAL_COMMENT}       |
      | PM_INST       | ${PM_INSTRUCTION}         |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_UPDATED_FILENAME} |

    And I process the workflow template file "${ORDER_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_ORDERS                           |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                     |
      | EMAIL_TO                | testautomation@eastspring.com               |
      | EMAIL_SUBJECT           | SANITY TEST PUBLISH ORDERS                  |
      | PUBLISH_LOAD_SUMMARY    | true                                        |
      | SUCCESS_ACTION          | DELETE                                      |
      | FILE_PATTERN            | ${ORDER_UPDATED_FILENAME}                   |
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
    AND AOST.GEN_CNT =2
    """

    #Load reserach report and update BRS order
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    Then I extract a value from the XML file "testout/dmp-interfaces/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ResearchReportWrapper/flowResultIdQuery.xpath" to variable "flowResultId"

    And I execute below query and extract values of "UPDATE_JOB_ID" into same variables
      """
      SELECT JOB_ID AS UPDATE_JOB_ID FROM FT_T_JBLG where INSTANCE_ID='${flowResultId}' AND JOB_CONFIG_TXT='EIS_ResearchReportTag_Update'
      """

    Then I expect value of column "TRID_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS TRID_COUNT FROM FT_T_TRID
    WHERE job_id = '${UPDATE_JOB_ID}'
    AND MAIN_ENTITY_ID IN (select AUOR_OID from gs_gc.FT_T_AUOR  WHERE PREF_ORDER_ID IN ('${ORDER_NUMBER}') AND ACCT_ID is not null)
    """

    Examples: Order Parameters
      | CategoryTemplate       | ReportScenario                             | TargetLowerPrice | TargetUpperPrice | Reportprice | ReportTrnType | ReportPortfolio | ReportTempPortfolio | ReportAssetID | AssetID   | TranType | BasketID       | PortfolioTicker | Quantity | TradePurpose                  | LimitPrice | MarketPrice | IsCompliance | PMInstruction | IntComment       |
      | DEQTemplate.txt        | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | DAMTemplate.txt        | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TD00105             | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW DAM Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQTemplate.txt        | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQIncomeTemplate.txt  | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ Income Buy Sell   | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGCInfraTemplate.txt | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GC Infra Buy Sell | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | OEQGemTemplate.txt     | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW OEQ GEM Buy Sell      | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |
      | GFITemplate.txt        | DMP not updating Report tagged (Buy) order | 2345             | 5150             | 3750        | Buy           | TSTTT16         | TT16                | SB1VJS642     | SB1VJS642 | BUY      | TEST_API_ORDER | TSTTT16         | 1000     | ESI. TW GFI Buy Sell          | 3750       | 200         | false        | TW_RES_TAGGED | ${INTERNAL_LINK} |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory