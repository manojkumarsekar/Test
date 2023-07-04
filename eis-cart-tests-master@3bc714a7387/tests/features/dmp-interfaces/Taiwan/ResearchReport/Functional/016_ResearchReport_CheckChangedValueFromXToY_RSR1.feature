@tom_3876 @dmp_twrr_functional @dmp_tw_functional
Feature: Test Research Report for changing values for fields in report

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security
  This feature will test the changes in value from X to Y in report
  Expected Result: Research report workflow will load the report and load only value Y in RSR1 table

  #  Prerequisite step to setup portfolio and link with account group as required for research report
  Scenario: TC2:Load portfolio Template with Main portfolio details to Setup new accounts in DMP
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "eis_dmp_Mainportfolio_TW_UAT.xlsx" to variable "PORTFOLIO_TEMPLATE"
    And I assign "400" to variable "workflow.max.polling.time"
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

  Scenario Outline: validate research report for changing values in fields for categoty <CategoryTemplate> and scenario <ReportScenario>
    Given I generate value with date format "DHs" and assign to variable "VAR_RANDOM"
    And I generate value with date format "YYYY-MM-dd" and assign to variable "VAR_DATE"
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

    Then I pause for 15 seconds

    #Load reserach report and update BRS order
    And I process the workflow template file "${RESEARCHREPORT_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE       | EITW_MT_RESEARCH_REPORT |
      | BRS_WEBSERVICE_URL | ${brs.api.order.url}    |

    #Verify EXT_RSRSH_EXPIRY_DTE= EXT_RSRSH_PUB_TMS + 90
    Then I expect value of column "RSR1_RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RSR1_RECORD_COUNT FROM ft_t_rsr1 where trunc(EXT_RSRSH_EXPIRY_DTE)= trunc(EXT_RSRSH_PUB_TMS) + 90
    AND EXT_RSRSH_ID ='${INTERNAL_LINK}'
    AND EXT_TRGT_PRC_UPPER='5140'
    AND EXT_TRGT_PRC_LOWER='2350'
    AND TRN_CDE='BUY'
    """

    Examples: Order Parameters
      | CategoryTemplate       | ReportScenario            | TargetLowerPrice | TargetUpperPrice | Reportprice | ReportTrnType | ReportPortfolio | ReportTempPortfolio | ReportAssetID |
      | DEQTemplate.txt        | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | DAMTemplate.txt        | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | OEQTemplate.txt        | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | OEQIncomeTemplate.txt  | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | OEQGCInfraTemplate.txt | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | OEQGemTemplate.txt     | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |
      | GFITemplate.txt        | Changed value from X to Y | 2300 to 2350     | 5000 to 5140     | 3750        | Sell to Buy   | TSTTT16         | TT16                | SB1VJS642     |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory