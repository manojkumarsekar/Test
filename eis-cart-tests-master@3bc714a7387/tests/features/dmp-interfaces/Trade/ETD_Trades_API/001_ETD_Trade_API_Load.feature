#https://jira.pruconnect.net/browse/EISDEV-7135
#Functional specification : https://collaborate.pruconnect.net/display/EISTOM/Blockchain+ETD+trade+file#businessRequirements-overview
#EISDEV-7136: Adding publishing and verification
#EISDEV-7314: Fixed INVNUM issue
#EISDEV-7567: Including the OPTION scope
#EISDEV-7608: Fixes for conditions of OPTION T and T+7 date checks

@gc_interface_trades
@dmp_regression_unittest
@eisdev_7135 @001_etd_trade_api_load @eisdev_7136 @eisdev_7314 @eisdev_7567 @eisdev_7608

Feature: Load ETD trades via API

  The purpose of this interface is to source ETD trades for T-7 to T+7.
  The request goes to Aladdin via API and trades are sourced filtered on Port Group & Trade Date and stored in DMP in FT_T_ETR1 custom table

  Scenario:TC1: Initialize variables

    Given I assign "tests/test-data/dmp-interfaces/Trade/ETD_Trades_API" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I execute below query and extract values of "DATE_T_MINUS_7;DATE_T;DATE_T_PLUS_7" into same variables
     """
     select to_char(sysdate-7, 'YYYY-MM-DD') AS DATE_T_MINUS_7, to_char(sysdate, 'YYYY-MM-DD') AS DATE_T,
     to_char(sysdate+7, 'YYYY-MM-DD') AS DATE_T_PLUS_7 from dual
     """

    And I modify date "${DATE_T_MINUS_7}" with "-0d" from source format "YYYY-MM-dd" to destination format "dd/MM/YYYY" and assign to "DATE_T_MINUS_7_OP"
    And I modify date "${DATE_T}" with "-0d" from source format "YYYY-MM-dd" to destination format "dd/MM/YYYY" and assign to "DATE_T_OP"
    And I modify date "${DATE_T_PLUS_7}" with "-0d" from source format "YYYY-MM-dd" to destination format "dd/MM/YYYY" and assign to "DATE_T_PLUS_7_OP"


  Scenario:TC2: Create trades for T-7, T & T+7 for SecGroup = FUTURE and SecType = FIN,INDEX

    Given I place BRS Trade with following trade economics
      | TRADE_PRICE      | 10                |
      | CUSIP            | DEDZ42023         |
      | CPRTY_NAME       | CONV              |
      | TRADE_QTY        | 1000              |
      | PORTFOLIO_TICKER | TSTTT16           |
      | TRADE_DATE       | ${DATE_T_MINUS_7} |
      | TRAN_TYPE        | BUY               |

    And I place BRS Trade with following trade economics
      | TRADE_PRICE      | 1000      |
      | CUSIP            | DEDZ42023 |
      | CPRTY_NAME       | CONV      |
      | TRADE_QTY        | 1000      |
      | PORTFOLIO_TICKER | TSTTT16   |
      | TRADE_DATE       | ${DATE_T} |
      | TRAN_TYPE        | BUY       |

    And I place BRS Trade with following trade economics
      | TRADE_PRICE      | 100              |
      | CUSIP            | DEDZ42023        |
      | CPRTY_NAME       | CONV             |
      | TRADE_QTY        | 1000             |
      | PORTFOLIO_TICKER | TSTTT16          |
      | TRADE_DATE       | ${DATE_T_PLUS_7} |
      | TRAN_TYPE        | BUY              |

    And I place BRS Trade with following trade economics
      | TRADE_PRICE      | 100       |
      | CUSIP            | SBD5DMY28 |
      | CPRTY_NAME       | CONV      |
      | TRADE_QTY        | 1000      |
      | PORTFOLIO_TICKER | TSTTT16   |
      | TRADE_DATE       | ${DATE_T} |
      | TRAN_TYPE        | BUY       |

  Scenario:TC2: Create trades for T-7, T & T+7 for SecGroup = OPTION and SecType = EQUITY,FUTURE

    Given I place BRS Trade with following trade economics
      | TRADE_PRICE      | 10                |
      | CUSIP            | Z94LWCFA4         |
      | CPRTY_NAME       | CONV              |
      | TRADE_QTY        | 1000              |
      | PORTFOLIO_TICKER | TSTTT16           |
      | TRADE_DATE       | ${DATE_T_MINUS_7} |
      | TRAN_TYPE        | BUY               |

    And I place BRS Trade with following trade economics
      | TRADE_PRICE      | 1000      |
      | CUSIP            | Z94LWCFA4 |
      | CPRTY_NAME       | CONV      |
      | TRADE_QTY        | 1000      |
      | PORTFOLIO_TICKER | TSTTT16   |
      | TRADE_DATE       | ${DATE_T} |
      | TRAN_TYPE        | BUY       |

    And I place BRS Trade with following trade economics
      | TRADE_PRICE      | 100              |
      | CUSIP            | BRTU182T9        |
      | CPRTY_NAME       | CONV             |
      | TRADE_QTY        | 1000             |
      | PORTFOLIO_TICKER | TSTTT16          |
      | TRADE_DATE       | ${DATE_T_PLUS_7} |
      | TRAN_TYPE        | BUY              |

  Scenario:TC3: Load trades by invoking ETDTradeRequestReply Workflow

    Given I process Brs ETD RequestReply workflow with below parameters and wait for the job to be completed
      | BRS_PORT_GROUP            | ESITST_TW                           |
      | DIRECTORY                 | /dmp/in/brs/api                     |
      | MESSAGE_TYPE              | EIS_MT_BRS_API_TRANSACTION          |
      | END_DATE_RANGE            | 7                                   |
      | START_DATE_RANGE          | 7                                   |
      | OUTPUT_DIRECTORY          | /dmp/archive/in/brs/api             |
      | BRSPROPERTY_FILE_LOCATION | ${brscredentials.validfilelocation} |
      | BRS_WEBSERVICE_URL        | ${brswebservice.trade.url}          |

  Scenario:TC4: Verify if T-7 date trade was loaded in ETR1

    Given I expect value of column "TRADE_T_MINUS_7_FUTURE" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_MINUS_7_FUTURE from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T_MINUS_7}' and end_tms is null
      """

    And I expect value of column "TRADE_T_MINUS_7_OPTION" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_MINUS_7_OPTION from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4C' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T_MINUS_7}' and end_tms is null
      """

  Scenario:TC5: Verify if T date trade was loaded in ETR1

    Given I expect value of column "TRADE_T_FUTURE" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_FUTURE from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T}' and end_tms is null
      """

    And I expect value of column "TRADE_T_OPTION" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_OPTION from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4C' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T}' and end_tms is null
      """

  Scenario:TC6: Verify if T+7 date trade was loaded in ETR1

    Given I expect value of column "TRADE_T_PLUS_7_FUTURE" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_PLUS_7_FUTURE from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T_PLUS_7}' and end_tms is null
      """

    And I expect value of column "TRADE_T_PLUS_7_OPTION" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_PLUS_7_OPTION from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'DEDZ4C' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T}' and end_tms is null
      """

  Scenario:TC7: Verify if T date Equity trade was not loaded in ETR1

    And I expect value of column "TRADE_T_EQUITY" in the below SQL query equals to "PASS":
      """
      select case when count(1) > 1 then 'PASS' else 'FAIL' end as TRADE_T_EQUITY from ft_t_etr1 where ext_portfolio_ticker = 'TSTTT16'
      and ext_sec_ticker = 'BRTU182T9' and to_char(ext_trd_dte, 'YYYY-MM-DD') = '${DATE_T_PLUS_7}' and end_tms is null
      """

  Scenario: Publish STACS file for transactions after loading the data

    Given I assign "ETDTrade" to variable "PUBLISHING_FILE_NAME"
    And I assign "/opt/data/dmp/out/stacs" to variable "PUBLISHING_DIRECTORY"
    And I assign "ETDTrade_expected.csv" to variable "OUTPUT_TEMPLATENAME"
    And I assign "ETDTrade_runtime_expected.csv" to variable "OUTPUT_EXPECTED"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_STACS_TRANSACTION_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I create input file "${OUTPUT_EXPECTED}" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"

    Then I exclude below columns from CSV file while doing reconciliations
      | INVNUM |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${OUTPUT_EXPECTED}                          |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |
