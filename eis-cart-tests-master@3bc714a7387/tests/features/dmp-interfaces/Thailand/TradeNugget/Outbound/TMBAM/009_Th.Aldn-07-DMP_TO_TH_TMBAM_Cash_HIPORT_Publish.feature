#https://jira.pruconnect.net/browse/EISDEV-6484
#Functional Specification:https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND
#Technical Specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction
# Purpose : The purpose of this file to publish on market transactions(Cash) from DMP to TMBAM hiport.

# EISDEV-6631 Changes --START--
# XN_IM_DB_CODE2.0002 is mapped for aladdin bcusip in the publish file.Remove this mapping
# Map to XN_XREF_EXT_CODE.0001 to publish Aladdin Bcusip(Aladdin tag:CUSIP)
# EISDEV-6631 Changes --END--

# EISDEV-6787 Changes --START--
# Include ABS and TBILL to be published in TMBTXNFI.qqq
# EISDEV-6787 Changes --END--

# EISDEV-6824 Changes --START--
# On Mrkt|TRD_PRINCIPAL|Rounding off
# EISDEV-6824 Changes --END--

# EISDEV-6829 Changes --START--
# Rounding off as per HiPort spec
# EISDEV-6829 Changes --END--

#EISDEV-7172 Changes --START--
#For IDX On market transaction, please include - symbol if BRS provides values in negative for the TRD_INTEREST attribute
#Hiport Attribute name: XN_NATIVE_INCOME.0001
#BRS Mapping:TRD_INTEREST
#Sections impacted :FI Mapping & DS Mapping
#Files Impacted: TFTXNFI.qqq,TFCASH.qqq,TMBTXNFI.qqq,TMBCASH.qqq
# EISDEV-7172 Changes --END--

#EISDEV-7492 Changes --START--
#For IDX On market transaction, please remove negative symbol if BRS provides values in negative for the TRD_INTEREST attribute, It is rollback of 7172
#Hiport Attribute name: XN_NATIVE_INCOME.0001
#BRS Mapping:TRD_INTEREST
#Sections impacted :FI Mapping & DS Mapping
#Files Impacted: TFTXNFI.qqq,TFCASH.qqq,TMBTXNFI.qqq,TMBCASH.qqq
# EISDEV-7492 Changes --END--

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6484 @eisdev_6484_tmbam_cash @001_tmbam_onmarket_publish @dmp_thailand_hiport
@dmp_thailand @eisdev_6725 @eisdev_6787 @eisdev_6824 @eisdev_6829 @eisdev_7172 @eisdev_7492

Feature: Publish the TMBAM Cash trade in Hiport format

  This feature will test the below scenarios
  1. Load the FixedIncome security file received as part of the trade nugget
  2. Load the FixedIncome transaction file received as part of the trade nugget
  3. Publish the FixedIncome HiPort file

  SecGroup : CASH  | SecType : TD
  Security_ID   | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  BES34W3G0     | TMB22     | BHTMT13${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  BES3A1YW2     | TMB22     | BHTMT14${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  SecGroup : CASH  | SecType : CP
  Security_ID   | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  BES35YHP0     | TMB22     | BHTMT17${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  BES39ATJ9     | TMB22     | BHTMT18${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  SecGroup : CASH  | SecType : CD
  Security_ID   | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  BES35ABC0     | TMB22     | BHTMT19${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  BES39XYZ9     | TMB22     | BHTMT20${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Outbound/TMBAM" to variable "testdata.path"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Security Files
    And I assign "009_Th.Aldn-07-DMP_TO_TH_BRS_Cash_Security_F10_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "009_Th.Aldn-07-DMP_TO_TH_BRS_Cash_Security_F10" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "009_Th.Aldn-07-DMP_TO_TH_BRS_Cash_Transaction_F11_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "009_Th.Aldn-07-DMP_TO_TH_BRS_Cash_Transaction_F11" to variable "TRANSACTION_FILE"

    #Publish files and directory
    And I assign "009_Th_Aldn-07-DMP_TO_TH_TMBCASH_Template.qqq" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "009_Th_Aldn-07-DMP_TO_TH_TMBCASH_Expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "009_Th_Aldn-07-DMP_TO_TH_TMBCASH_Actual" to variable "PUBLISH_FILE_ACTUAL"

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
      | PUBLISHING_FILE_NAME        | DummyFile_Cash.qqq                      |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_CASH_SUB |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |

    Then I remove below files with pattern in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | DummyFile_* |


  Scenario:TC3: Load the security file, it is prerequisite file for OnMarket Publish

    Given I create input file "${SECURITY_FILE}_${VAR_SYSDATE}.xml" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW             |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with total record count as "6"

  Scenario:TC4: Load the Transaction file, it is prerequisite file for OnMarket Publish

    Given I create input file "${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION     |
      | BUSINESS_FEED |                                        |

    Then I expect workflow is processed in DMP with total record count as "6"

  Scenario:TC5: Publish the FixedIncome file in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}.qqq              |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_CASH_SUB |
      | FOOTER_COUNT                | 1                                       |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

  Scenario: TC6: Recon the FixedIncome published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq   |