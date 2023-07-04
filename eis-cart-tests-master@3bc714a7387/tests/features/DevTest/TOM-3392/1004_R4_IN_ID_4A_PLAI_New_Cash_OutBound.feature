#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844919
#https://jira.intranet.asia/browse/TOM-3392
#TOM-3392 : New outbound created for Indonesia new cash
#TOM-3595 : Trade date and Settle date format changed from dd/mm/yyyy to dd-mmm-yy
#TOM-4043: Modified ID-TA to BNP for Indo New cash

@gc_interface_cash
@dmp_regression_integrationtest
@tom_4043 @tom_3392 @1004_dmp_new_cash_dmp_to_brs
Feature: Outbound new cash from DMP to BRS Interface Testing (R4.IN-ID.4A - New Cash from TA/Client Indonesia DMP to BRS)

  Load new cash file with below records (details below), all containing EXTERN_NEWCASH_ID1, PORTFOLIO, AMOUNT, CURRENCY, CASH_TYPE, SETTLE_DATE, TRADE_DATE
  as mandatory fields and CANCEL, COMMENTS as optional field

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,CANCEL,COMMENTS
  123,NDSICF,"2,300,000",IDR,CASHIN,28-Jun-18,25-Jun-18,N,NewCash for NDSICF
  456,ADPSEF,"456,789.67",IDR,CASHOUT,28-Jun-18,22-Jun-18,N,
  789,NDSICF,"150,000",IDR,CASHIN,21-Jun-18,11-Jun-18,N,NewCash for NDSICF
  889,NDSICF,"0",IDR,CASHIN,21-Jun-18,11-Jun-18,N,NewCash for NDSICF
  989,NDSICF,"150,000",IDR,CASHIN,21-Jun-18,11-Jun-18,Y,CancelCash for NDSICF
  ,,,,,,,Y,NA

  Below records should be present in the outbound

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,AUTHORIZED_BY,CASH_REASON,COMMENTS,CONFIRMED_BY,ESTIMATED,SOURCE
  123,NDSICF,2300000,IDR,CASHIN,20180628,20180625,ID-TA,CCRE,NewCash for NDSICF,ID-TA,F,X
  456,ADPSEF,456789.67,IDR,CASHOUT,20180628,20180622,ID-TA,,,ID-TA,F,X

  Scenario: TC_1: Triggering Publishing Wrapper Event for Indonesia New Cash and Delete to clear the data loaded through other processes

    Given I assign "esi_dmp_to_brs_intraday_cashtrn_file367_new" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | ESII_DMP_TO_BRS_CTRN_FILE367_PLAI_SUB |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_2: Clear the Indonesia Cash data as a Prerequisite

    Given I assign "tests/test-data/DevTest/TOM-3392" to variable "testdata.path"
    And I assign "outfiles/actual/feature_1004" to variable "outfiles.actual"

    # Clear Indonesia Cash data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R4_IN_ID_4A_PLAI_SCB_New_Cash.sql
    """

  Scenario: TC_3: Load Indonesia New Cash File

    Given I assign "R4_IN_ID_4A_PLAI_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                            |
      | FILE_PATTERN  | ${INPUT_FILENAME}                          |
      | MESSAGE_TYPE  | ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION |

  Scenario: TC_4: Triggering Publishing Wrapper Event for CSV file into directory for Indonesia New Cash

    Given I assign "esi_dmp_to_brs_intraday_cashtrn_file367_new" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME    | ESII_DMP_TO_BRS_CTRN_FILE367_PLAI_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/${outfiles.actual}":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Check the attributes in the outbound file for Indonesia New Cash

    Given I assign "U_VAL_NEW_CASH_INDONESIA_MASTER_TEMPLATE.csv" to variable "NEW_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "NEW_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/${outfiles.actual}/${NEW_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/expected/${NEW_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_1004_tc5_${recon.timestamp}.csv" file

  Scenario: TC_6: Triggering Publishing Wrapper Event for CSV file into directory for Indonesia Cancel Cash

    Given I assign "esi_dmp_to_brs_intraday_cashtrn_file367_canc" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv              |
      | SUBSCRIPTION_NAME    | ESII_DMP_TO_BRS_CTRN_FILE367_PLAI_CN_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/${outfiles.actual}":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_7: Check the attributes in the outbound file for Indonesia Cancel Cash

    Given I assign "U_VAL_CANCEL_CASH_INDONESIA_MASTER_TEMPLATE.csv" to variable "CANCEL_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CANCEL_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/${outfiles.actual}/${CANCEL_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/expected/${CANCEL_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_1004_tc7_${recon.timestamp}.csv" file

  Scenario: TC_8: Clear the BNP data as a Prerequisite

    Given I assign "R4_IN_ID_4A_BNP_Test_File_For_Verification.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3392" to variable "testdata.path"

    # Clear BNP Cash data
    Given I execute below query
     """
     ${testdata.path}/sql/ClearData_R4_IN_ID_4A_BNP_New_Cash.sql
     """

  Scenario: TC_9: Load BNP New Cash File

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION |

  Scenario: TC_10: Triggering Publishing Wrapper Event for CSV file into directory for BNP New Cash - Regression Testing

    Given I assign "esi_dmp_to_brs_for_bnp_new_cash_intraday_cashtrn_file367_new" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CASHTRAN_FILE367_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/${outfiles.actual}":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_11: Check the attributes in the outbound file for BNP New Cash - Regression Testing

    Given I assign "U_VAL_NEW_CASH_BNP_MASTER_TEMPLATE.csv" to variable "NEW_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "NEW_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/${outfiles.actual}/${NEW_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/outfiles/expected/${NEW_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_1004_tc11_${recon.timestamp}.csv" file