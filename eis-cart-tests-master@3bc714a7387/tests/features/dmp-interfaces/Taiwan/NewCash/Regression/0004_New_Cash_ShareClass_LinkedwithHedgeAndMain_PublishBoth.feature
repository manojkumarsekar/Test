#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844919
#https://jira.intranet.asia/browse/TOM-3645
#TOM-3645 : New outbound created for Taiwan new cash
#TOM-4223 : Add two new (fixed) columns to output

@gc_interface_portfolios @gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3645 @taiwan_newcash @taiwan_newcash_hedge_portfolio @tom_4223
Feature: Outbound new cash from DMP to BRS Interface Testing Shareclass linked with main and hedge portfolio should publish cash for both the funds

  Load new cash file with below records (details below), all containing EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO
  as mandatory fields and CASH_REASON,ESTIMATED as optional field

  EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO,CASH_REASON,ESTIMATED
  TEST_20180521_00164,3000,CASHIN,TWD,20180521,20180521,TST-TRD8-SH-CLUBN_008,,E

  Below records should be present in the outbound

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,CASH_REASON,ESTIMATED,AUTHORIZED_BY,CONFIRMED_BY
  TEST_20180521_00064,TST-TRD5_0001,3000,TWD,CASHOUT,20180521,20180521,REDS,F,AUTO,AUTO

  Scenario: TC_1: Clear the Taiwan Cash data as a Prerequisite and set up account in DMP

    Given I assign "0004_TW_newcash_hedge.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"
    And I assign "0001-PortTemplate-TW-attributes_Exceptions.xlsx" to variable "PORTFOLIO_FILENAME"
    And I assign "esi_TW_newcash_outbound_hedge" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"
    And I assign "0004_expected_output_hedge.csv" to variable "NEW_CASH_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "NEW_CASH_CURR_FILE"

   # Clear Taiwan Cash data
    Given I execute below query
    """
    ${testdata.path}/sql/ClearData_R5_IN_CAS1_Intraday_New_Cash.sql
    """

    And I execute below query
    """
    UPDATE ft_t_acid SET  start_tms = SYSDATE - 1, end_tms = SYSDATE
    WHERE  ACCT_ID IN
    (
    SELECT ACCT_ID FROM ft_t_acid
    WHERE ACCT_ID_CTXT_TYP = 'RDMID'
    AND ACCT_ALT_ID IN ('TST-TRD1_0001','TST-TRD2_0001','TST-TRD3_0001','TST-TRD4_0001','TST-TRD5_0001','TST-TRD6_0001','TST-TRD7_0001','TST-TRD8_0001','TST-TRD8_0001_USD','TST-TRD1_0001_RDM','TST-TRD2_0001_RDM','TST-TRD3_0001_RDM','TST-TRD4_0001_RDM','TST-TRD5_0001_RDM','TST-TRD6_0001_RDM','TST-TRD7_0001_RDM','TST-TRD8_0001_RDM')
    AND end_tms IS NULL
    );
    COMMIT
    """

    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC_2: Load Taiwan New Cash File with same externalid with different portfolio, it should overwrite the previous load with new one and publish

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_TW_FAS_NEW_CASH |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
      """

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NewCash/testdata/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/testdata/outfiles/actual/${NEW_CASH_CURR_FILE}" and reference CSV file "${testdata.path}/testdata/outfiles/expected/${NEW_CASH_MASTER_TEMPLATE}" should be successful and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file