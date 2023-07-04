#https://jira.pruconnect.net/browse/EISDEV-6424
# Functional Specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=ACK%7CNACK+requirements+for+TMBAM%2CTFUND%7CBRS%3EDMP%3EHIPORT
# Purpose : For every trades sent from BRS(Aladdin), it accepts an acknowledgement(ACK) when the trade file is successfully loaded
# into the downstream application and negative acknowledgement(NACK) when the trade file is not successfully loaded into
# the downstream application.In case of TMBAM andTFUND, it will be a load and publish to respective Hiport applications.
# Since Hiport does not have the ACK/NACK feature it will be achieved through DMP outbound upon file been successfully
# published to ES SFTP under the out folders TMBAM/DMP_TO_TMBAM and TFUND/DMP_TO_TFUND.

@gc_interface_portfolios @gc_interface_transactions @gc_interface_trades
@dmp_regression_integrationtest
@eisdev_6424 @eisdev_6559 @eisdev_6424_tfund_tradeacknack @tradeacknack @dmp_thailand_tradeacknack @dmp_thailand @eisdev_6593 @eisdev_6865
@eisdev_6877 @eisdev_6908 @eisdev_7172 @eisdev_7492
Feature: Publish Thailand TFund Trade ACK NACK To BRS

  Scenario: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNACK_ACKToBRS" to variable "TESTDATA.PATH"
    And I assign "001_tfund_brs_to_dmp_tfund_F54_portfolio.xml" to variable "INPUT_F54_FILENAME"
    And I assign "001_tfund_tradefile_Testcase_1" to variable "INPUT_TRADE_FILENAME_1"
    And I assign "001_tfund_tradefile_Testcase_2" to variable "INPUT_TRADE_FILENAME_2"
    And I assign "001_tfund_tradefile_Testcase_2_B_104" to variable "INPUT_TRADE_FILENAME_2_B_104"
    And I assign "001_tfund_tradefile_Testcase_3" to variable "INPUT_TRADE_FILENAME_3"
    And I assign "001_tfund_eod_tradefile" to variable "INPUT_EOD_TRADE_FILENAME"

    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHDIRECTORY_ACK_NACK"
    And I assign "001_tfund_ack_nack_out_file_Testcase_1" to variable "PUBLISHING_ACK_NACK_FILE_NAME_1"
    And I assign "001_tfund_ack_nack_out_file_Testcase_2" to variable "PUBLISHING_ACK_NACK_FILE_NAME_2"

    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHDIRECTORY_HIPORT_INTRADAY"
    And I assign "001_tfund_hiport_fi_out_file" to variable "PUBLISHING_FILE_NAME_FI_TFUND_HIPORT"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query and extract values of "CURR_DATE_1;CURR_DATE_2" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_1, TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_2 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

  Scenario: Create BRSFundID using File54 from BRS, it is prerequisite file for OnMarket Publish

    When I process "${TESTDATA.PATH}/infiles/template/${INPUT_F54_FILENAME}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with total record count as "1"

    And I execute below query to create participants for TFund- TFB-AG group
    """
    ${TESTDATA.PATH}/sql/001_InsertIntoACGPTable_TFund.sql
    """

  Scenario: Load Trades using TH Intraday Messagetype for Touchcount 1

  INVNUM=-BHTFTN101${TRD_VAR_NUM_1} BND - Touchcount 1-  cancel trade with mandatory field TRADE_SETTLEDATE missing to get exception - NACK will be sent trade is not created
  INVNUM=-BHTFTN102${TRD_VAR_NUM_1} BND - Touchcount 1- trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 -  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTFTN103${TRD_VAR_NUM_1} BND - Touchcount 1- executed trade (TRD_TRADER populated and TRD_REVIEWED_BY empty)-  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTFTN104${TRD_VAR_NUM_1} BND - Touchcount 1- confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin-  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTFTN105${TRD_VAR_NUM_1} BND  - Touchcount 1- TH_Hiport_ID is missing to get exception of severity 40(i.e TH_Hiport_ID(UDF) is mandatory for Thailand FI securities.) - for this NACK will be sent as hiport id is missing
  INVNUM=-BHTFTN106${TRD_VAR_NUM_1} Equity  - Touchcount 1- It helps to test the TRY_SEND scenario -  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP

    Given I create input file "${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml" using template "001_tfund_tradefile_F11_template_Testcase_1.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_1}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION           |
      | BUSINESS_FEED |                                              |

    Then I expect workflow is processed in DMP with total record count as "6"

  Scenario: Load Trades using EOD Messagetype - EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM
  INVNUM=-BHTFED107${TRD_VAR_NUM_1} BND - confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin- but this EOD trade should not published to ACK file

    Given I create input file "${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml" using template "001_tfund_eod_tradefile_F11_template.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_EOD_TRADE_FILENAME}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM           |
      | BUSINESS_FEED |                                                |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 2

  INVNUM=-BHTFTN102${TRD_VAR_NUM_1} BND - Touchcount 2 -trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - ACK Message with TRADE HAS BEEN UPLOADED INTO DMP
  INVNUM=-BHTFTN103${TRD_VAR_NUM_1} BND - Touchcount 2 -executed trade (TRD_TRADER populated and TRD_REVIEWED_BY empty) (cancel status) - ACK Message with CANCELLED TRADE HAS BEEN LOADED INTO DMP
  INVNUM=-BHTFTN106${TRD_VAR_NUM_1} Equity - Touchcount 2 - ACK and NACK message should not publish to BRS because it has not send to Hiport

    Given I create input file "${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml" using template "001_tfund_tradefile_F11_template_Testcase_2.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_2}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION           |
      | BUSINESS_FEED |                                              |

    Then I expect workflow is processed in DMP with total record count as "3"

  Scenario: Publish Trade ACK or NACK before publish to Hiport

  It helps to validate after Hiport publish should send ACK message to BRS for INVNUM=-BHTFTN102 as TRADE HAS BEEN PUBLISHED TO HIPORT

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

    Given I create input file "001_tfund_trade_ack_nack_expected_Testcase_1_${VAR_SYSDATE}.xml" using template "001_tfund_trade_ack_nack_template_Testcase_1.xml" from location "${TESTDATA.PATH}/outfiles"
    Then I expect each record in file "${TESTDATA.PATH}/outfiles/testdata/001_tfund_trade_ack_nack_expected_Testcase_1_${VAR_SYSDATE}.xml" should exist in file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml" and exceptions to be written to "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_exceptions_${VAR_SYSDATE}.xml" file

  Scenario: Verify trade is loaded using the EOD Messagetype should not publish to ACK file before hiport publish
    Given I expect element count from the xml file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_1}_${VAR_SYSDATE}_1.xml" by xpath "//TMSACKS//TMSACK/INVNUM[text()='-BHTFED107${TRD_VAR_NUM_1}']" should be 0

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 2 for BHTFTN104

  INVNUM=-BHTFTN104${TRD_VAR_NUM_1} BND - Touchcount 2 - confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin-  ACK Message with TRADE HAS BEEN UPLOADED INTO DMP

    Given I create input file "${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml" using template "001_tfund_tradefile_F11_template_Testcase_2_B_104.xml" from location "${TESTDATA.PATH}/infiles"

    When I process "${TESTDATA.PATH}/infiles/testdata/${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${INPUT_TRADE_FILENAME_2_B_104}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                 |
      | BUSINESS_FEED |                                                    |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Publish trade files to TFund FI in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" if exists:
      | ${PUBLISHING_FILE_NAME_FI_TFUND_HIPORT}*.qqq |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_FI_TFUND_HIPORT}.qqq |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_FI_SUB       |
      | FOOTER_COUNT                | 1                                           |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                        |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" after processing:
      | ${PUBLISHING_FILE_NAME_FI_TFUND_HIPORT}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHDIRECTORY_HIPORT_INTRADAY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA.PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_FI_TFUND_HIPORT}_${VAR_SYSDATE}_1.qqq |

  Scenario: Verify Published trades to Hiport status should be SENT including intraday and EOD messagetype

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND   GEN_CNT = 1
      AND DATA_SRC_ID = 'THANA'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('217-BHTFTN104${TRD_VAR_NUM_1}','217-BHTFTN102${TRD_VAR_NUM_1}','217-BHTFED107${TRD_VAR_NUM_1}') AND  END_TMS IS NULL
      )
      """

  Scenario: Load Trades using TH Intraday Messagetype for below TouchCount 3 to validate NACK Scenerios for CANCEL and SendtoHiport

  INVNUM=-BHTFTN102${TRD_VAR_NUM_1} BND - Touchcount 3 -trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - NACK Message with TRADE BEEN PUBLISHED TO HIPORT,AMENDMENT CANNOT BE SENT
  INVNUM=-BHTFTN104${TRD_VAR_NUM_1} BND - Touchcount 3- confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) and trade sent to Hiport fund admin-  NACK Message for cancel as TRADE BEEN PUBLISHED TO HIPORT,AMENDMENT CANNOT BE SENT

    Given I create input file "${INPUT_TRADE_FILENAME_3}_${VAR_SYSDATE}.xml" using template "001_tfund_tradefile_F11_template_Testcase_3.xml" from location "${TESTDATA.PATH}/infiles"

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

    Given I create input file "001_tfund_trade_ack_nack_expected_Testcase_2_${VAR_SYSDATE}.xml" using template "001_tfund_trade_ack_nack_template_Testcase_2.xml" from location "${TESTDATA.PATH}/outfiles"
    Then I expect each record in file "${TESTDATA.PATH}/outfiles/testdata/001_tfund_trade_ack_nack_expected_Testcase_2_${VAR_SYSDATE}.xml" should exist in file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml" and exceptions to be written to "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_exceptions_${VAR_SYSDATE}.xml" file

  Scenario: Verify trade is loaded using the EOD Messagetype should not publish to ACK file after Hiport publish
    Given I expect element count from the xml file "${TESTDATA.PATH}/outfiles/runtime/${PUBLISHING_ACK_NACK_FILE_NAME_2}_${VAR_SYSDATE}_1.xml" by xpath "//TMSACKS//TMSACK/INVNUM[text()='-BHTFED107${TRD_VAR_NUM_1}']" should be 0

  Scenario: Verify ACK or NACK delivered Status message updated into EXST table Gen_Reas_txt column

    Given I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "8":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE DATA_SRC_ID = 'BRS'
      AND GEN_REAS_TXT = 'ACK or NACK Send to BRS'
      AND LAST_CHG_USR_ID ='EITH_DMP_BRS_TRADE_STATUS_ACK'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('217-BHTFTN102${TRD_VAR_NUM_1}','217-BHTFTN103${TRD_VAR_NUM_1}','217-BHTFTN104${TRD_VAR_NUM_1}','217-BHTFTN106${TRD_VAR_NUM_1}') AND  END_TMS IS NULL
      )
      """
