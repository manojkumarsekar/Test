#https://jira.pruconnect.net/browse/EISDEV-6363
#Functional Specification:https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+On+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND
#Technical Specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-07-+DMP+to+Thailand%28TFund+and+TMBAM%29+Hiport+-+OnMarket+Transaction
# Purpose : The purpose of this file to publish on market transactions(FixedIncome) from DMP to TFUND hiport.

# EISDEV-6426 Changes --START--
# Txn type change to 03 & 04 for EQ and MF buy and sell transaction
# Remove the neagative signs for INVNUM under XN_CONTRACT.0001 and XN_ITR_ID_10.0001 attributes
# Apply new logic for XN_NATIVE_BROKERAGE.0001 and XN_NATIVE_STAMP.0001 attribute,TMBAM and TFUND separately
# Apply new logic for TFUND transaction under XN_EXP_CODE1,2,3,4,5.
# EISDEV-6426 Changes --END--

# EISDEV-6430 Changes --START--
# Change the mapping logic for EQ,FUND,FI,DS asset types
# XN_NATIVE_COST.0001        TRD_PRINCIPAL
# XN_NATIVE_PROCEEDS.0001    TRD_PRINCIPAL
# Remove XN_BROKER2_CODE.0001 mapping
# EISDEV-6430 Changes --END--

# EISDEV-6422 Changes --START--
# Added mapping for TD,TBILL,CP,CD,ABS
# Removed mapping of XN_CREATOR.0001, XN_FILE_PATH.0001
# Added BUY condition for NET_COST and SELL condition for PROCEEDS
# EISDEV-6422 Changes --END--

# EISDEV-6459 Changes --START--
# TFUND|Publish On market transaction|DMP to Hiport|CMDTY,ABS
# EISDEV-6459 Changes --END--

# EISDEV-6480 Changes --START--
# Sort Buy Transactions Followed By Sell Transactions In The Publish File Based On Derived Tran_Type.Applicable To All Asset Classes
# EISDEV-6480 Changes --END--

# EISDEV-6484 Changes --START--
# CASH & ABS separated to be published in different files
# EISDEV-6484 Changes --END--

# EISDEV-6585 Changes --START--
# Incorrect TranType published
# EISDEV-6585 Changes --END--

# EISDEV-6580 Changes --START--
# XN_NATIVE_BROKERAGE.0001> TRD_COMMISSION
# XN_NATIVE_STAMP.0001>CHARGE_SUB-CATS=VATA
# EISDEV-6580 Changes --END--

# EISDEV-6606 Changes --START--
# XN_NATIVE_BROKERAGE.0001	TMBAM:TRD_COMMISSION
# TFUND:TRD_COMMISSION+CHARGE_SUB-CATS=VATA
# XN_NATIVE_STAMP.0001	TMBAM:CHARGE_SUB-CATS=VATA
# TFUND: BLANK#
# EISDEV-6606 Changes --END--

# EISDEV-6655 Changes --START--
# Included Hiport Sec Id for EQ,FD,DS,ABS,CMDTY
# EISDEV-6655 Changes --END--

# EISDEV-6696 Changes --START--
# Split portfolio logic to publish main portfolio code for split portfolios
# EISDEV-6696 Changes --END--

# EISDEV-6739 Changes --START--
# Issue_date and maturity_date > 1 year then FI else DS
# EISDEV-6739 Changes --END--

# EISDEV-6787 Changes --START--
# Include ABS and TBILL to be published in TMBTXNFI.qqq
# EISDEV-6787 Changes --END--

# EISDEV-6824 Changes --START--
# On Mrkt|TRD_PRINCIPAL|Rounding off
# EISDEV-6824 Changes --END--

# EISDEV-6829 Changes --START--
# Rounding off as per HiPort spec
# EISDEV-6829 Changes --END--

# EISDEV-6748 Changes --START--
# no.of.days between Issue_date and maturity_date = 1 year then DS
# EISDEV-6748 Changes --END--

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
@eisdev_6363 @eisdev_6363_tfund_fi @001_tfund_onmarket_publish @dmp_thailand_hiport @dmp_thailand
@eisdev_6426 @eisdev_6430 @eisdev_6422 @eisdev_5921 @eisdev_6459 @eisdev_6480 @eisdev_6484 @eisdev_6565 @eisdev_6580
@eisdev_6655 @eisdev_6696 @eisdev_6725 @eisdev_6739 @eisdev_6717 @eisdev_6787 @eisdev_6795 @eisdev_6824 @eisdev_6829
@eisdev_6748 @eisdev_7172 @eisdev_7492

Feature: Publish the TFund FixedIncome trade in Hiport format

  This feature will test the below scenarios
  1. Load Portfolio files to create portfolios
  2. Load the FixedIncome security file received as part of the trade nugget
  3. Load the FixedIncome transaction file received as part of the trade nugget
  4. Publish the FixedIncome HiPort file

  SecGroup : BND  | CouponType : Fixed(F) | Maturity Date <> First Pay Date
  Security_ID     | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  IN0020190396    | 217     | BHTFD505${TRD_VAR_NUM_1}  | BUY              | ${CURR_DATE_1}   |
  XS1497605805    | 217     | BHTFD606${TRD_VAR_NUM_1}  | SELL             | ${CURR_DATE_1}   |

  SecGroup : BND  | CouponType : Floating(T)
  Security_ID     | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  XS0149623281    | 217     | BHTFD707${TRD_VAR_NUM_1}  | BUY              | ${CURR_DATE_1}   |
  XS0284753497    | 217     | BHTFD808${TRD_VAR_NUM_1}  | SELL             | ${CURR_DATE_1}   |

  SecGroup : BND  | CouponType : Zero Coupon (Z) | It is called Discounted Security
  Security_ID     | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  US912803DM22    | 217     | BHTFD909${TRD_VAR_NUM_1}  | BUY              | ${CURR_DATE_1}   |
  US912803FM04    | 217     | BHTFD100${TRD_VAR_NUM_1}  | SELL             | ${CURR_DATE_1}   |

  SecGroup : BND  | CouponType : Fixed(F) | Maturity Date = First Pay Date
  Security_ID     | Fund_ID | Transaction_ID            | Transaction_Type | Transaction_Date |
  BES34WLC9       | 217     | BHTFDS11${TRD_VAR_NUM_1}  | BUY              | ${CURR_DATE_1}   |
  BES34WLD7       | 217     | BHTFDS22${TRD_VAR_NUM_1}  | SELL             | ${CURR_DATE_1}   |
  BES34WLC9       | 217_S   | BHTFDS33${TRD_VAR_NUM_1}  | BUY              | ${CURR_DATE_1}   |

  SecGroup : ABS  | SecType : ABS
  Security_ID     | Fund_ID   | Transaction_ID            | Transaction_Type | Transaction_Date |
  TH7647031B04    | TF235     | BHTFD21${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  TH694103UB05    | TF235     | BHTFD22${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  SecGroup : CASH  | SecType : TBILL
  Security_ID      | Fund_ID   | Transaction_ID            | Transaction_Type | Transaction_Date |
  BES2R9YL3        | TF200     | BHTFD15${TRD_VAR_NUM_1}   | BUY              | ${CURR_DATE_1}   |
  BES31DZ62        | TF200     | BHTFD16${TRD_VAR_NUM_1}   | SELL             | ${CURR_DATE_1}   |

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Outbound/TFUND" to variable "testdata.path"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Portfolio Files
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "001_Th.Aldn-07-DMP_TO_TH_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    #Security Files
    And I assign "003_Th.Aldn-07-DMP_TO_TH_BRS_FixedIncome_Security_F10_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "003_Th.Aldn-07-DMP_TO_TH_BRS_FixedIncome_Security_F10" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "003_Th.Aldn-07-DMP_TO_TH_BRS_FixedIncome_Transaction_F11_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "003_Th.Aldn-07-DMP_TO_TH_BRS_FixedIncome_Transaction_F11" to variable "TRANSACTION_FILE"

    #Publish files and directory
    And I assign "003_Th_Aldn-07-DMP_TO_TH_TFTXNFI_Template.qqq" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "003_Th_Aldn-07-DMP_TO_TH_TFTXNFI_Expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "003_Th_Aldn-07-DMP_TO_TH_TFTXNFI_Actual" to variable "PUBLISH_FILE_ACTUAL"

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
      | PUBLISHING_FILE_NAME        | DummyFile_FI.qqq                      |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_FI_SUB |
      | FOOTER_COUNT                | 1                                     |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                  |

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

  Scenario:TC4: Load the security file, it is prerequisite file for OnMarket Publish

    Given I create input file "${SECURITY_FILE}_${VAR_SYSDATE}.xml" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW             |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with success record count as "12"

  Scenario:TC5: Load the Transaction file, it is prerequisite file for OnMarket Publish

    Given I create input file "${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION     |
      | BUSINESS_FEED |                                        |

    Then I expect workflow is processed in DMP with success record count as "13"
    Then I expect workflow is processed in DMP with total record count as "14"

  Scenario:TC6: Verify TH_Hiport_ID rows count for Success and Failure

    Given I expect value of column "ETCM_PROCESSED_ROW_COUNT" in the below SQL query equals to "7":
    """
    SELECT COUNT (1) AS ETCM_PROCESSED_ROW_COUNT
    FROM FT_T_ETCM
    WHERE CMNT_REAS_TYP IN ('HIPORTSECID')
    AND   LN_NUM =1 AND
    EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID
                     FROM FT_T_EXTR
                     WHERE TRD_ID IN ('217-BHTFD505${TRD_VAR_NUM_1}','217-BHTFD606${TRD_VAR_NUM_1}',
                                   '217-BHTFD707${TRD_VAR_NUM_1}','217-BHTFD808${TRD_VAR_NUM_1}',
                                   '217-BHTFD909${TRD_VAR_NUM_1}',
                                   '217-BHTFDS11${TRD_VAR_NUM_1}','217-BHTFDS22${TRD_VAR_NUM_1}'

                                  )
                   )
    """

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 2b: BRS Issuer ID not in [R86074, R61053] portfolio code not equal to DPLUS, Strategy != 334. However, TFHIPORTID is not present on the security. TRD_ID = 217-BHTFDT011${TRD_VAR_NUM_1} |
      | NOTFCN_ID               | 60036                                                                                                                                                                                                    |
      | SOURCE_ID               | %_GC%                                                                                                                                                                                                    |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                                                                                       |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                                                                                     |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                                                                                     |
      | MAIN_ENTITY_ID          | 217:-BHTFDT011${TRD_VAR_NUM_1}                                                                                                                                                                           |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                                                                                       |

  Scenario:TC7: Publish the FixedIncome file in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_FI_SUB |
      | FOOTER_COUNT                | 1                                     |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                  |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.qqq |

  Scenario: TC8: Recon the FixedIncome published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.qqq   |