#https://jira.pruconnect.net/browse/EISDEV-6484
#Functional Specification:https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND
#Technical Specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction
# Purpose : The purpose of this file to publish on market transactions(ABS) from DMP to TMBAM hiport.

# EISDEV-6631 Changes --START--
# XN_IM_DB_CODE2.0002 is mapped for aladdin bcusip in the publish file.Remove this mapping
# Map to XN_XREF_EXT_CODE.0001 to publish Aladdin Bcusip(Aladdin tag:CUSIP)
# EISDEV-6631 Changes --END--

# EISDEV-6787 Changes --START--
# Include ABS and TBILL to be published in TMBTXNFI.qqq
# EISDEV-6787 Changes --END--

@ignore
@eisdev_6484 @eisdev_6484_tmbam_abs @001_tmbam_onmarket_publish @dmp_thailand_hiport @dmp_thailand @eisdev_6725

Feature: Publish the TMBAM ABS trade in Hiport format

  This feature will test the below scenarios
  1. Load the FixedIncome security file received as part of the trade nugget
  2. Load the FixedIncome transaction file received as part of the trade nugget
  3. Publish the FixedIncome HiPort file

  SecGroup : ABS  | SecType : ABS
  Security_ID   | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  TH7647031B04  | TMB22     | BHTMT11${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  TH694103UB05  | TMB22     | BHTMT12${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Outbound/TMBAM" to variable "testdata.path"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Security Files
    And I assign "010_Th.Aldn-07-DMP_TO_TH_BRS_ABS_Security_F10_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "010_Th.Aldn-07-DMP_TO_TH_BRS_ABS_Security_F10" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "010_Th.Aldn-07-DMP_TO_TH_BRS_ABS_Transaction_F11_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "010_Th.Aldn-07-DMP_TO_TH_BRS_ABS_Transaction_F11" to variable "TRANSACTION_FILE"

    #Publish files and directory
    And I assign "010_Th_Aldn-07-DMP_TO_TH_TMBABS_Template.qqq" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "010_Th_Aldn-07-DMP_TO_TH_TMBABS_Expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "010_Th_Aldn-07-DMP_TO_TH_TMBABS_Actual" to variable "PUBLISH_FILE_ACTUAL"

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

  Scenario:TC2: Load the security file, it is prerequisite file for OnMarket Publish

    Given I create input file "${SECURITY_FILE}_${VAR_SYSDATE}.xml" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW             |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC3: Load the Transaction file, it is prerequisite file for OnMarket Publish

    Given I create input file "${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION     |
      | BUSINESS_FEED |                                        |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC4: Publish the FixedIncome file in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}.qqq             |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TMBAM_HIPORT_TRADE_ABS_SUB |
      | FOOTER_COUNT                | 1                                      |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

  Scenario: TC5: Recon the FixedIncome published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq   |