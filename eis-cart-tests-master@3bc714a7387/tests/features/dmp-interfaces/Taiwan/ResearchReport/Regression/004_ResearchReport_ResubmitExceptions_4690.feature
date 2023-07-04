#https://jira.intranet.asia/browse/TOM-4690
#Creating shell security from Research Report email using BCUSIP would lead us to problems of creating split security which we have encountered below.
#Security should only be created from Order file and F10 which is currently happening in prod.

@gc_interface_research_report @gc_interface_portfolios
@dmp_regression_integrationtest
@dmp_taiwan
@004_rr_resubmit_exception @tom_4690
Feature: Test Research Report for missing security in DMP. Security would be created from Order file. Research Report process will resubmit those exceptions.

  Raise exception when security is not found during RR load.
  Research Report will only be used for tagging when order is placed on corresponding security.
  Security will be created in DMP when order is loaded.
  Resubmit all the exceptions on RR related to missing security before running tagging process in DMP. We should be looking for exceptions raised in last 90 days since that is maximum time RR will be valid.
  Resubmit will create all the RR for which security was created from Order file and will be tagged to orders when tagging process runs.

  # Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
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

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'S53435103'"

  Scenario: Validate Resubmit for Research Report workflow

    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I assign "400" to variable "workflow.max.polling.time"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
    And I assign "esi_orders_${VAR_RANDOM}.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "${brs.research.report.link}${VAR_RANDOM}" to variable "INTERNAL_LINK"
    And I assign "DAM_BRS_ISIN_Template.txt" to variable "EMAIL_TEMPLATE"

    And I execute below query
    """
    DELETE from FT_T_RSP1 where trunc(START_TMS)=trunc(SYSDATE);
    DELETE from FT_T_RSR1 where trunc(START_TMS)=trunc(SYSDATE);
    DELETE from FT_T_RSR1 WHERE EXT_RSRSH_ID = '${INTERNAL_LINK}' AND END_TMS IS NULL;
    COMMIT
    """

    When I send research report email for category "${EMAIL_TEMPLATE}" to common mail box with below details
      | PORTFOLIO          | U_TT56        |
      | TEMP_PORTFOLIO     | TT56          |
      | REPORT_DATE        | ${VAR_DATE}   |
      | CUSIP              | S53435103     |
      | TW_Buy_Sell        | Buy           |
      | PRICE              | 3127.75       |
      | LINK               | ${VAR_RANDOM} |
      | Target_Price_Lower | 1,930         |
      | Target_Price_Upper | 3,850         |
      | NEW_END_DATE       |               |

    Then I pause for 50 seconds

    #Load reserach report and update BRS order
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    #Verify Research Report not loaded
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(1) AS RECORD_COUNT FROM FT_T_RSR1 WHERE EXT_RSRSH_ID = '${INTERNAL_LINK}' AND END_TMS IS NULL
    """

    When I Post Order using BRS API with below details
      | ASSET_ID          | S66226911            |
      | ORDER_TRAN_TYPE   | BUY                  |
      | BASKET_ID         | TEST_API_ORDER       |
      | PORTFOLIO_TICKER  | U_TT56_S             |
      | QUANTITY          | 1000                 |
      | TRADE_PURPOSE     | ESI. TW DAM Buy Sell |
      | LIMIT_PRICE       | 2500                 |
      | MARKET_PRICE      | 3000                 |
      | PM_INITIALS       |                      |
      | IS_RUN_COMPLIANCE | false                |

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
      | CUSIP         | S53435103                 |
      | PORTFOLIO     | U_TT56_S                  |
      | QUANTITY      | 1000                      |
      | LIMIT_PRICE   | 2500                      |
      | MARKET_PRICE  | 3000                      |
      | BASKET_ID     | TEST_API_ORDER            |
      | ORDERNUMBER   | ${brs.api.order.number}   |
      | TRANTYPE      | BUY                       |
      | TRADE_PURPOSE | ESI. TW DAM Buy Sell      |

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

    #Load reserach report
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    #Verify Research Report not loaded
    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) AS RECORD_COUNT FROM FT_T_RSR1 WHERE EXT_RSRSH_ID = '${INTERNAL_LINK}' AND END_TMS IS NULL
    """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory