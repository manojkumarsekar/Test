#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844919
#https://jira.intranet.asia/browse/TOM-3500
#TOM-3500 : New outbound created for Indonesia misc cash
#TOM-3595 : Trade date and Settle date format changed from dd/mm/yyyy to dd-mmm-yy
#TOM-3654 : ESID Misc/New cash interface changes

@gc_interface_cash
@dmp_regression_integrationtest
@tom_3500 @tom_3595 @tom_3654 @misc_cash_outbound
Feature: Outbound misc cash from DMP to BRS Interface Testing (R4.IN-CAS11 - MISC Cash from PLAI Indonesia DMP to BRS)

  Load misc cash file with below records (details below), all containing EXTERN_NEWCASH_ID1, PORTFOLIO, AMOUNT, CURRENCY, CASH_TYPE, SETTLE_DATE, TRADE_DATE as mandatory fields
  and CANCEL, COMMENTS as optional field

  CURRENCY,PORTFOLIO,TRADE_DATE,SETTLE_DATE,PRINCIPAL,COMMENTS
  IDR,NDSICF,25/06/2018,26/06/2018,10000.10,TOM-3500 TICKET AUTOMATED TESTING
  IDR,ADPSEF,27/06/2018,28/06/2018,20000.20,TOM-3500 TICKET AUTOMATED TESTING
  IDR,NDSICF,29/06/2018,30/06/2018,30000.30,TOM-3500 TICKET AUTOMATED TESTING
  ,,,,30000.30,TOM-3500 TICKET AUTOMATED TESTING

  Below records should be present in the outbound

  CURRENCY,CUSIP,PORTFOLIO,SETTLE_DATE,SUB_TRAN_TYPE,TRADE_DATE,TRAN_TYPE,PRINCIPAL,AUTHORIZED_BY,COMMENTS,CONFIRMED_BY
  IDR,XIDR0000,NDSICF,20180630,MGMT_FEE,20180629,MISC,30000.3,ID-TA,TOM-3500 TICKET AUTOMATED TESTING,ID-TA
  IDR,XIDR0000,NDSICF,20180626,MGMT_FEE,20180625,MISC,10000.1,ID-TA,TOM-3500 TICKET AUTOMATED TESTING,ID-TA
  IDR,XIDR0000,ADPSEF,20180628,MGMT_FEE,20180627,MISC,20000.2,ID-TA,TOM-3500 TICKET AUTOMATED TESTING,ID-TA

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R4_IN_CAS11_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3500" to variable "testdata.path"

    # Clear data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R4_IN_CAS11_MISC_Cash.sql
    """

  Scenario: TC_2: Load misc cash File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME}                     |
      | MESSAGE_TYPE  | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION |

  Scenario: TC_3: Triggering Publishing Wrapper Event for CSV file into directory for Indonesia MISC Cash and Delete to clear the data loaded through other processes

    Given I assign "esi_dmp_to_brs_intraday_cashtrn_file314_misc" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME    | ESII_DMP_TO_BRS_CASHTRAN_FILE314_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3500/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check the attributes in the outbound file for Indonesia misc cash

    Given I assign "MISC_CASH_INDONESIA_MASTER_TEMPLATE.csv" to variable "MISC_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "MISC_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${MISC_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/reference/${MISC_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_5: Clear the BNP data as a Prerequisite to clear the test Cash data from DMP before load and publish

    Given I assign "R4_IN_CAS11_BNP_Test_File_For_Verification.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3500" to variable "testdata.path"

    # Clear BNP Cash data
    Given I execute below query
     """
     ${testdata.path}/sql/ClearData_R4_IN_CAS11_BNP_MISC_Cash.sql
     """

  Scenario: TC_6: Load BNP misc cash File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

  Scenario: TC_7: Triggering Publishing Wrapper Event for CSV file into directory for BNP misc cash - Regression Testing

    Given I assign "esi_dmp_to_brs_intraday_cashtrn_file314_misc" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHTRAN_FILE314_SUB                                                               |
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                       |
      | SQL                  | &lt;sql&gt; TRD_LEGEND_TXT = 'TRANSFORMER-CONFIRMED-MANAGEMENTFEE-PACSLINK-15082018' &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3500/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_8: Check the attributes in the outbound file for BNP misc cash - Regression Testing

    Given I assign "MISC_CASH_BNP_MASTER_TEMPLATE.csv" to variable "MISC_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "MISC_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${MISC_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/reference/${MISC_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_bnp_${recon.timestamp}.csv" file
