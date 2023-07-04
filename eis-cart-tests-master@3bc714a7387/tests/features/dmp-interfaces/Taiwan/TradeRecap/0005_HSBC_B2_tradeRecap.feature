#https://jira.intranet.asia/browse/TOM-4818

@gc_interface_transactions @gc_interface_trades @gc_interface_portfolios @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4818 @trade_recap @trade_recap_hsbc_b2 @eisdev_7114
Feature: Test Publishing of HSBC Trade Recap data for batch 2

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "Options.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/TradeRecap" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_4818.sql
    """

  Scenario: Setup new account in DMP

    Given I assign "TOM_4818.xlsx" to variable "PORTFOLIO_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: Setup new account group and Financial Role Account Participant data in DMP linked to above account

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_CAP2_FRAP_HSBC_4818.sql
    """

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "TRD_1_hsbc.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_out_file_1_B2_4818" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4818-4818') AND  END_TMS IS NULL
      )
      """

  Scenario: Check the outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

#Check if PORTFOLIO CUSIP has value BPM21EWK5 in the outbound
    Given I expect column "CUSIP" value to be "BPM21EWK5" where columns values are as below in CSV file "${CSV_FILE}"
      | FUND                      | 4818     |
      | INVNUM                    | -4818    |
      | PORTFOLIOS_PORTFOLIO_NAME | Test4818 |
      | SM_SEC_GROUP              | OPTION   |
      | SM_SEC_TYPE               | CUROTC   |
      | TRAN_TYPE1                | TRD      |
      | TICKER                    | COJ9P    |
      | TRD_CURRENCY              | JPY      |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
    ${testdata.path}/sql/Clear_EXTR_EXST_HSBC_4818.sql
    """

  Scenario: Load Fresh data for Trades 4818-4818

    Given I assign "TRD_2_hsbc.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 1
      AND TASK_CMPLTD_CNT = 1
      """

  Scenario: Load 17292-EISDEV71142 and 17293-EISDEV71143 trades to validate Fund and sitca id on Trade Count Report

    Given I assign "TRD_Count_hsbc_b2_UltimateFund_Sitca_ID_7114.xml" to variable "INPUT_FILENAME"

    Given I process "${testdata.path}/infiles/${INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with total record count as "2"
    And fail record count as "0"

  Scenario: Remove operational data for trade recap publishing
            ## to test trade count control report subsequent to next publication

    Given I execute below query to "clear publishing history for subsequent trade count scenario"
    """
    DELETE ft_cfg_pub1
    WHERE  start_tms > TRUNC(SYSDATE)
    AND    subscription_nme LIKE 'EITW%HSBC%TRADEFLOW%B2%'
    """

  Scenario: Publish trade recap file for HSBC

    Given I assign "traderecap_hsbc_out_file_2_B2_4818" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/hsbc" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_HSBC_TRADEFLOW_B2 |
      | EXTRACT_STREETREF_TO_SUBMIT | true                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status
    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'HSBC'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('4818-4818','17292-EISDEV71142','17293-EISDEV71143') AND  END_TMS IS NULL
      )
      """

  Scenario: Check the outbound file

    Given I assign "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"
#Check if PORTFOLIO CUSIP has value BPM21EWK5 in the outbound
    Given I expect column "CUSIP" value to be "BPM21EWK5" where columns values are as below in CSV file "${CSV_FILE}"
      | FUND                      | 4818     |
      | INVNUM                    | -4818    |
      | PORTFOLIOS_PORTFOLIO_NAME | Test4818 |
      | SM_SEC_GROUP              | OPTION   |
      | SM_SEC_TYPE               | CUROTC   |
      | TRAN_TYPE1                | TRD      |
      | TICKER                    | COJ9P    |
      | TRD_CURRENCY              | TWD      |

  Scenario: Run trade recap record count control report

    Given I assign "esi_TW_TRConReport_HSBC_B2_${VAR_SYSDATE}.htm" to variable "OUTPUT_FILENAME"

    And I remove below files in the host "dmp.ssh.outbound" from folder "/dmp/out/taiwan" if exists:
      | ${OUTPUT_FILENAME} |

    And I process the workflow template file "tests/test-data/intf-specs/gswf/template/EIS_XmlQueryTransform/request.xmlt" with below parameters and wait for the job to be completed
      | EMAIL_ADDRESSES  | raja.ramalingam@eastspring.com                                      |
      | EMAIL_MESSAGE    |                                                                     |
      | EMAIL_SENDER     | eis-cart-test@eastspring.com                                        |
      | EMAIL_SUBJECT    | Trade recap feature file run B2 (HSBC)                              |
      | FILENAME         | /dmp/out/taiwan/${OUTPUT_FILENAME}                                  |
      | QUERY_PARAMETER1 | FundAdmin:HSBC                                                      |
      | QUERY_PARAMETER2 | Batch:B2                                                            |
      | QUERY_PARAMETER3 | Date:${VAR_SYSDATE}                                                 |
      | QUERY_URI        | db://resource/xml/query/estw_trade_recap_counts.sql                 |
      | REC_COUNT_XPATH  | /data/row[@fund!='Total']                                           |
      | XSLT_URI         | db://resource/xml/xslt/EASTSPRING/estw_trade_recap_counts_html.xslt |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "/dmp/out/taiwan" after processing:
      | ${OUTPUT_FILENAME} |

    When I copy files below from remote folder "/dmp/out/taiwan" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${OUTPUT_FILENAME} |


  #Validate Ultimate parent(TT190) should display in Fund and DIOF8 in Sitca column for TT190 and TT190_S Funds
    Then I expect value from xml file "${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME}" with xpath "/html/body/table/tr[td[1]='TT190']/td[2]" should be "DIOF8"

   #Validate Child fund (TT190_S) should not display in the report
    Then I expect value from xml file "${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME}" with xpath "//td[contains(text(),'TT190_S')]" should be ""


