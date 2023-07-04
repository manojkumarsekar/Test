#https://jira.pruconnect.net/browse/EISDEV-6469
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+FFX+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND
#Technical Specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+FFX+Transaction
# Purpose : The purpose of this file to publish ffx transactions(fx) from DMP to TFUND hiport.

# EISDEV-6575 Changes --START--
# OFX_H_FORMAT.0001 :Hardcoded as 'P'
# OFX_BROKER_EXT_CODE.0001:TRD_COUNTERPARTY
# OFX_FUND.0001:2 digit number derived based on portfolio code and portfolio group
# EISDEV-6575 Changes --END--

# EISDEV-6589 Changes --START--
# OFX_BROKER_EXT_CODE.0001> Based on TRDREL_INVNUM lookup for TRD_COUNTERPATY
# OFX_TRADE_NOMINAL.0001> Based on TRDREL_INVNUM lookup for FX_PAY_AMT
# OFX_COUNTER_NOMINAL.000>Based on TRDREL_INVNUM lookup for FX_RCV_AMT
# XZ_SPOT_RATE.0001>Based on TRDREL_INVNUM lookup for FX_PRICE_SPOT
# XZ_FWD_RATE.0001>Based on TRDREL_INVNUM lookup for FX_PRICE_SPOT
# EISDEV-6589 Changes --END--

# EISDEV-6696 Changes --START--
# Split portfolio logic to publish main portfolio code for split portfolios
# EISDEV-6696 Changes --END--

# EISDEV-6772 Changes --START--
# FX FWRD MAT+/MAT- should not be published for TFUND
# For FX SPOT,If the TRD_FIFO_TYPE in ('OPEN','CLOSED') then OFX_OPEN_CLOSE_FLAG.0001 ='O'
# TRD_PRICE for XZ_SPOT_RATE.0001 & XZ_FWD_RATE.0001
# EISDEV-6772 Changes --END--

# EISDEV-6794 Changes --START--
# FX_PRICE for XZ_SPOT_RATE.0001 & XZ_FWD_RATE.0001
# EISDEV-6794 Changes --END--

# EISDEV-6829 Changes --START--
# Rounding off as per HiPort spec
# EISDEV-6829 Changes --END--

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6469 @eisdev_6469_tfund_ffx @001_tfund_ffx_publish @dmp_thailand_hiport @dmp_thailand
@eisdev_6575 @eisdev_6589 @eisdev_6696 @eisdev_6725 @eisdev_6772 @eisdev_6794 @eisdev_6829

Feature: Publish the TFund FFX trade in Hiport format

  This feature will test the below scenarios
  1. Load Portfolio files to create portfolios
  2. Load the FFX security file received as part of the trade nugget
  3. Load the FFX transaction file received as part of the trade nugget
  4. Publish the FFX HiPort file

  SecGroup : FX  | SecType : SPOT
  Security_ID   | Fund_ID | Transaction_ID              | Transaction_Type  | Transaction_Date  | Group
  BES3B5TL2     | 217     | TFFXSPOT111${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPRV
  BES3B5VA3     | 217     | TFFXSPOT222${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFPRV
  BES3B5TL2     | 235     | TFFXSPOT333${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFMUT
  BES3B5VA3     | 235     | TFFXSPOT444${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFMUT
  BES3B5TL2     | 200     | TFFXSPOT555${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPVD
  BES3B5VA3     | 200     | TFFXSPOT666${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFPVD
  BES3B5TL2     | 217     | TFFXSPOT777${TRD_VAR_NUM_1} | MAT-              | ${CURR_DATE_1}    | TFPRV
  BES3B5VA3     | 217     | TFFXSPOT888${TRD_VAR_NUM_1} | MAT+              | ${CURR_DATE_1}    | TFPRV
  BES3B5TL2     | 217_S   | TFFXSPOT999${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPRV


  SecGroup : FX  | SecType : FWRD
  Security_ID   | Fund_ID | Transaction_ID              | Transaction_Type  | Transaction_Date  | Group
  BES3B6US3     | 217     | TFFXFWRD111${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPRV
  BES3B6UR5     | 217     | TFFXFWRD222${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFPRV
  BES3B6US3     | 235     | TFFXFWRD333${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFMUT
  BES3B6UR5     | 235     | TFFXFWRD444${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFMUT
  BES3B6US3     | 200     | TFFXFWRD555${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPVD
  BES3B6UR5     | 200     | TFFXFWRD666${TRD_VAR_NUM_1} | SELL              | ${CURR_DATE_1}    | TFPVD
  BES3B6US3     | 217     | TFFXFWRD777${TRD_VAR_NUM_1} | MAT-              | ${CURR_DATE_1}    | TFPRV
  BES3B6UR5     | 217     | TFFXFWRD888${TRD_VAR_NUM_1} | AMT+              | ${CURR_DATE_1}    | TFPRV
  BES3B6US3     | 217     | TFFXFWRD999${TRD_VAR_NUM_1} | BUY               | ${CURR_DATE_1}    | TFPRV

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Outbound/TFUND" to variable "testdata.path"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Portfolio Files
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "001_Th.Aldn-07-DMP_TO_TH_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    #Security Files
    And I assign "008_Th.Aldn-07-DMP_TO_TH_BRS_FFX_Security_F10_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "008_Th.Aldn-07-DMP_TO_TH_BRS_FFX_Security_F10" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "008_Th.Aldn-07-DMP_TO_TH_BRS_FFX_Transaction_F11_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "008_Th.Aldn-07-DMP_TO_TH_BRS_FFX_Transaction_F11" to variable "TRANSACTION_FILE"

    #Publish files and directory
    And I assign "008_Th_Aldn-07-DMP_TO_TH_TFFFX_Template.qqq" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "008_Th_Aldn-07-DMP_TO_TH_TFFFX_Expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "008_Th_Aldn-07-DMP_TO_TH_TFFFX_Actual" to variable "PUBLISH_FILE_ACTUAL"

    And I execute below query and extract values of "CURR_DATE_1;CURR_DATE_2;CURR_DATE_3;CURR_DATE_4" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_1, TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_2,
     TO_CHAR(sysdate, 'YYMMDD') AS CURR_DATE_3,TO_CHAR(sysdate+1, 'YYMMDD') AS CURR_DATE_4 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    #Trigger publish to clear any unpublished files
  Scenario: TC2: Publish any unpublished files to clear the log
    Given I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | *.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | DummyFile_FX.qqq                       |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_FFX_SUB |
      | FOOTER_COUNT                | 1                                      |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | DummyFile_* |

  Scenario:TC3: Load the portfolio uploader file, F54 and port group file to create portfolios required for transaction load

    When I process "${testdata.path}/inputfiles/template/${PORTFOLIO_UPLOADER_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPLOADER_FILE}           |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "5"

    When I process "${testdata.path}/inputfiles/template/${PORTFOLIO_F54_FILE}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PORTFOLIO_F54_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with success record count as "4"

    When I process "${testdata.path}/inputfiles/template/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with success record count as "8"

  Scenario:TC4: Load the security file, it is prerequisite file for FFX Publish

    Given I create input file "${SECURITY_FILE}_${VAR_SYSDATE}.xml" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW             |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with success record count as "4"

  Scenario:TC5: Load the Transaction file, it is prerequisite file for FFX Publish

    Given I create input file "${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION     |
      | BUSINESS_FEED |                                        |

    Then I expect workflow is processed in DMP with success record count as "18"

  Scenario:TC6: Publish the FX file in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}.qqq             |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_FFX_SUB |
      | FOOTER_COUNT                | 1                                      |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

  Scenario: TC7: Recon the FX published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq   |