#https://jira.pruconnect.net/browse/EISDEV-6424
# Functional Specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=ACK%7CNACK+requirements+for+TMBAM%2CTMBAM%7CBRS%3EDMP%3EHIPORT
# Purpose : For every trades sent from BRS(Aladdin), it accepts an acknowledgement(ACK) when the trade file is successfully loaded
# into the downstream application and negative acknowledgement(NACK) when the trade file is not successfully loaded into
# the downstream application.In case of TMBAM andTMBAM, it will be a load and publish to respective Hiport applications.
# Since Hiport does not have the ACK/NACK feature it will be achieved through DMP outbound upon file been successfully
# published to ES SFTP under the out folders TMBAM/DMP_TO_TMBAM and TMBAM/DMP_TO_TMBAM.

@gc_interface_portfolios @gc_interface_transactions @gc_interface_trades
@dmp_regression_integrationtest
@eisdev_6424 @eisdev_6559 @eisdev_6424_tmbam_tradeacknack @tradeacknack @dmp_thailand_tradeacknack @dmp_thailand @eisdev_6865 @eisdev_6877
@eisdev_6593 @eisdev_6725 @eisdev_6908 @eisdev_7172 @eisdev_7492

Feature: Publish Thailand TMBAM Trade ACK NACK To BRS

  Scenario: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNACK_ACKToBRS" to variable "TESTDATA.PATH"

    #Portfolio Files
    And I assign "001_DMP_TO_TH_TMBAM_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "001_DMP_TO_TH_TMBAM_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "001_DMP_TO_TH_TMBAM_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    And I assign "001_tmbam_tradefile_Testcase_1" to variable "INPUT_TRADE_FILENAME_1"
    And I assign "001_tmbam_tradefile_Testcase_2" to variable "INPUT_TRADE_FILENAME_2"
    And I assign "001_tmbam_tradefile_Testcase_2_B_104" to variable "INPUT_TRADE_FILENAME_2_B_104"
    And I assign "001_tmbam_tradefile_Testcase_3" to variable "INPUT_TRADE_FILENAME_3"
    And I assign "001_tmbam_eod_tradefile" to variable "INPUT_EOD_TRADE_FILENAME"

    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHDIRECTORY_ACK_NACK"
    And I assign "001_tmbam_ack_nack_out_file_Testcase_1" to variable "PUBLISHING_ACK_NACK_FILE_NAME_1"
    And I assign "001_tmbam_ack_nack_out_file_Testcase_2" to variable "PUBLISHING_ACK_NACK_FILE_NAME_2"

    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHDIRECTORY_HIPORT_INTRADAY"
    And I assign "001_tmbam_hiport_fi_out_file" to variable "PUBLISHING_FILE_NAME_FI_TMBAM_HIPORT"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query and extract values of "CURR_DATE_1;CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_1, TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_2 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

  Scenario:Load the portfolio uploader file, F54 and port group file to create portfolios required for transaction load

    When I process "${TESTDATA.PATH}/infiles/template/${PORTFOLIO_UPLOADER_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPLOADER_FILE}           |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "1"

    When I process "${TESTDATA.PATH}/infiles/template/${PORTFOLIO_F54_FILE}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PORTFOLIO_F54_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with success record count as "1"

    When I process "${TESTDATA.PATH}/infiles/template/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Load Trades using TH Intraday Messagetype for Touchcount 1
  INVNUM=-BHTMTN101${TRD_VAR_NUM_1} BND - Touchcount 1 - cancel trade with mandatory field TRADE_SETTLEDATE missing to get exception - NACK will be sent trade is not created
  INVNUM=-BHTMTN102${TRD_VAR_NUM_1} BND - Touchcount 1 - trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTMTN103${TRD_VAR_NUM_1} BND - Touchcount 1 - executed trade (TRD_TRADER populated and TRD_REVIEWED_BY empty) -  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTMTN104${TRD_VAR_NUM_1} BND - Touchcount 1 - confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin- ACK will be sent - ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTMTN105${TRD_VAR_NUM_1} BND  - Touchcount 1 - TH_Hiport_ID is missing to get exception of severity 40(i.e TH_Hiport_ID(UDF) is mandatory for Thailand FI securities.) - for this NACK will be sent as hiport id is missing
  INVNUM=-BHTMTN106${TRD_VAR_NUM_1} Equity  - Touchcount 1 -It helps to test the TRY_SEND scenario -  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTMTN108{TRD_VAR_NUM_1} Equity  - Touchcount 1 - It is not part of ES-MUT account group so it should not send to Hiport and it should publish to BRS as TRADE HAS BEEN UPLOADED INTO DMP


    Given I create input file "${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml" using template "001_tmbam_tradefile_F11_template_Testcase_1.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION           |
      | BUSINESS_FEED |                                              |

    Then I expect workflow is processed in DMP with total record count as "7"

  Scenario: Load Trades using EOD Messagetype - EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM
  INVNUM=-BHTMED107${TRD_VAR_NUM_1} BND - confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin- but this EOD trade should not published to ACK file

    Given I create input file "${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml" using template "001_tmbam_eod_tradefile_F11_template.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM           |
      | BUSINESS_FEED |                                                |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 2

  INVNUM=-BHTMTN102${TRD_VAR_NUM_1} BND - Touchcount 2 -trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTMTN103${TRD_VAR_NUM_1} BND - Touchcount 2 -executed trade (TRD_TRADER populated and TRD_REVIEWED_BY empty) (cancel status) - ACK Message with CANCELLED TRADE HAS BEEN LOADED INTO DMP
  INVNUM=-BHTMTN106${TRD_VAR_NUM_1} Equity - Touchcount 2 - ACK and NACK message should not publish to BRS because it has not send to Hiport

    Given I create input file "${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml" using template "001_tmbam_tradefile_F11_template_Testcase_2.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION           |
      | BUSINESS_FEED |                                              |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario: Publish Trade ACK or NACK before publish to Hiport

  It helps to validate after Hiport publish should send ACK message to BRS for INVNUM=-BHTMTN102  as TRADE HAS BEEN PUBLISHED TO HIPORT

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHDIRECTORY_ACK_NACK}" if exists:
      | ${PUBLISHING_ACK_NACK_FILE_NAME_1}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_ACK_NACK_FILE_NAME_1}.xml |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_BRS_TRADE_ACK_NACK_SUB     |
      | UNESCAPE_XML                | true                                   |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHDIRECTORY_ACK_NACK}" after processing:
      | ${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "${PUBLISHDIRECTORY_ACK_NACK}" on host "dmp.ssh.inbound" into local folder "${TESTDATA.PATH}/outfiles/runtime":
      | ${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml |

  Scenario: Verify Trade ACK or NACK before publish to Hiport scenario

    Given I create input file "001_tmbam_trade_ack_nack_expected_Testcase_1_${VAR_SYSDATE}.xml" using template "001_tmbam_trade_ack_nack_template_Testcase_1.xml" from location "${TESTDATA.PATH}/outfiles"
    Then I expect each record in file "${TESTDATA.PATH}/outfiles/testdata/001_tmbam_trade_ack_nack_expected_Testcase_1_${VAR_SYSDATE}.xml" should exist in file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml" and exceptions to be written to "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_exceptions_${VAR_SYSDATE}.xml" file

  Scenario: Verify trade is loaded using the EOD Messagetype should not publish to ACK file before hiport publish
    Given I expect element count from the xml file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml" by xpath "//TMSACKS//TMSACK/INVNUM[text()='-BHTMED107${TRD_VAR_NUM_1}']" should be 0

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 2 for BHTMTN104

  INVNUM=-BHTMTN104${TRD_VAR_NUM_1} BND - Touchcount 2- confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin-  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP

    Given I create input file "${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml" using template "001_tmbam_tradefile_F11_template_Testcase_2_B_104.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                 |
      | BUSINESS_FEED |                                                    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Publish trade files to TMBAM FI in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" if exists:
      | ${PUBLISHING_FILE_NAME_FI_TMBAM_HIPORT}_*.qqq |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_FI_TMBAM_HIPORT}.qqq |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_FI_SUB       |
      | FOOTER_COUNT                | 1                                           |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                        |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" after processing:
      | ${PUBLISHING_FILE_NAME_FI_TMBAM_HIPORT}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA.PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_FI_TMBAM_HIPORT}_${VAR_SYSDATE}_1.qqq |

  Scenario: Verify Published trades to Hiport status should be SENT including intraday and EOD messagetype

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'TMBAM'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('11821-BHTMTN104${TRD_VAR_NUM_1}','11821-BHTMTN102${TRD_VAR_NUM_1}','11821-BHTMED107${TRD_VAR_NUM_1}') AND  END_TMS IS NULL
      )
      """

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 3 to validate NACK Scenerios for CANCEL and SendtoHiport

  INVNUM=-BHTMTN102${TRD_VAR_NUM_1} BND - Touchcount 3 -trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - NACK Message with TRADE BEEN PUBLISHED TO HIPORT,AMENDMENT CANNOT BE SENT
  INVNUM=-BHTMTN104${TRD_VAR_NUM_1} BND - Touchcount 3- confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin - NACK Message for cancel as TRADE BEEN PUBLISHED TO HIPORT,AMENDMENT CANNOT BE SENT

    Given I create input file "${INPUT_TRADE_FILENAME_3}_${VAR_SYSDATE}.xml" using template "001_tmbam_tradefile_F11_template_Testcase_3.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_3}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_3}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION           |
      | BUSINESS_FEED |                                              |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: Publish Trade ACK or NACK after publish to Hiport

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHDIRECTORY_ACK_NACK}" if exists:
      | ${PUBLISHING_ACK_NACK_FILE_NAME_2}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_ACK_NACK_FILE_NAME_2}.xml |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_BRS_TRADE_ACK_NACK_SUB     |
      | UNESCAPE_XML                | true                                   |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHDIRECTORY_ACK_NACK}" after processing:
      | ${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "${PUBLISHDIRECTORY_ACK_NACK}" on host "dmp.ssh.inbound" into local folder "${TESTDATA.PATH}/outfiles/runtime":
      | ${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml |

  Scenario: Verify Trade ACK or NACK after publish to Hiport scenario

    Given I create input file "001_tmbam_trade_ack_nack_expected_Testcase_2_${VAR_SYSDATE}.xml" using template "001_tmbam_trade_ack_nack_template_Testcase_2.xml" from location "${TESTDATA.PATH}/outfiles"
    Then I expect each record in file "${TESTDATA.PATH}/outfiles/testdata/001_tmbam_trade_ack_nack_expected_Testcase_2_${VAR_SYSDATE}.xml" should exist in file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml" and exceptions to be written to "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_exceptions_${VAR_SYSDATE}.xml" file

  Scenario: Verify trade is loaded using the EOD Messagetype should not publish to ACK file after hiport publish also
    Given I expect element count from the xml file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml" by xpath "//TMSACKS//TMSACK/INVNUM[text()='-BHTMED107${TRD_VAR_NUM_1}']" should be 0

  Scenario: Verify ACK or NACK delivered Status message updated into EXST table Gen_Reas_txt column

    Given I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "9":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE DATA_SRC_ID = 'BRS'
      AND GEN_REAS_TXT = 'ACK or NACK Send to BRS'
      AND LAST_CHG_USR_ID ='EITH_DMP_BRS_TRADE_STATUS_ACK'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('11821-BHTMTN102${TRD_VAR_NUM_1}','11821-BHTMTN103${TRD_VAR_NUM_1}','11821-BHTMTN104${TRD_VAR_NUM_1}','11821-BHTMTN106${TRD_VAR_NUM_1}','16426-BHTMTN108${TRD_VAR_NUM_1}') AND  END_TMS IS NULL
      )
      """