#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844919
#https://jira.intranet.asia/browse/TOM-3645
#TOM-3645 : New outbound created for Taiwan new cash
#TOM-4223 : Add two new (fixed) columns to output

@tom_3847_out @tom_3645 @dmp_interfaces @taiwan_dmp_interfaces @taiwan_newcash @tom_4223
Feature: Outbound new cash from DMP to BRS Interface Testing (R5.IN-CAS9 DMP->BRS Intraday New Cash Transactions)

  Load new cash file with below records (details below), all containing EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO
  as mandatory fields and CASH_REASON,ESTIMATED as optional field

  EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO,CASH_REASON,ESTIMATED
  TEST_20180521_0000060,10900000,CASHIN,TWD,20180521,20180521,TST-TRD1-SH-CLUBN,,E
  TEST_20180521_0000061,10100000,CASHOUT,USD,20180521,20180521,TST-TRD2-SH-CLUBN,,F
  TEST_20180521_0000062,10100000,CASHOUT,USD,20180521,20180521,TST-TRD3-SH-CLUBN,,F
  TEST_20180521_0000063,,,,20180521,20180521,TST-TRD3-SH-CLUBN,,F
  Below records should be present in the outbound

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,CASH_REASON,ESTIMATED,AUTHORIZED_BY,CONFIRMED_BY
  TEST_20180521_0000061,TST-TRD2,10100000,USD,CASHOUT,20180521,20180521,REDS,F,AUTO,AUTO
  TEST_20180521_0000062,TST-TRD3,10100000,USD,CASHOUT,20180521,20180521,REDS,F,AUTO,AUTO
  TEST_20180521_0000060,TST-TRD1,10900000,TWD,CASHIN,20180521,20180521,SUBS,E,AUTO,AUTO


  Scenario: TC_1: Clear the Taiwan Cash data as a Prerequisite

    Given I assign "TW_newcash_inbound.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"

    # Clear Taiwan Cash data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R5_IN_CAS1_Intraday_New_Cash.sql
    """

  Scenario: TC_2: Load Taiwan New Cash File

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_TW_FAS_NEW_CASH |

  Scenario: TC_3: Triggering Publishing Wrapper Event for CSV file into directory for Taiwan New Cash

    Given I assign "esi_TW_newcash_outbound" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    #And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
     # | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NewCash/testdata/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check the attributes in the outbound file for Taiwan New Cash

    Given I assign "U_VAL_NEW_CASH_TAIWAN_MASTER_TEMPLATE.csv" to variable "NEW_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "NEW_CASH_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/testdata/outfiles/actual/${NEW_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/testdata/outfiles/expected/${NEW_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file