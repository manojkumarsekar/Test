#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45844919
#https://jira.intranet.asia/browse/TOM-3645
#TOM-3645 : New outbound created for Taiwan new cash

@gc_interface_portfolios @gc_interface_cash
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3645 @taiwan_newcash @taiwan_newcash_exceptions
Feature: Loading Taiwan FAS new cash into DMP Interface Testing for missing mandatory fields

  Load new cash FAS file with below records (details below),  containing EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO
  as mandatory fields and CASH_REASON,ESTIMATED as optional field

  EXTERN_NEWCASH_ID1,AMOUNT,CASH_TYPE,CURRENCY,TRADE_DATE,SETTLE_DATE,PORTFOLIO,CASH_REASON,ESTIMATED
  TEST_20180521_00060,3000,CASHINN,TWD,20180521,20180521,TST-TRD1-SH-CLUBN_001,,E
  ,3000,CASHOUT,TWD,20180521,20180521,TST-TRD2-SH-CLUBN_002,,F
  TEST_20180521_00062,,CASHIN,TWD,20180521,20180521,TST-TRD3-SH-CLUBN_003,,E
  TEST_20180521_00063,3000,,TWD,20180521,20180521,TST-TRD4-SH-CLUBN_004,,F
  TEST_20180521_00064,3000,CASHIN,,20180521,20180521,TST-TRD5-SH-CLUBN_005,,E
  TEST_20180521_00065,3000,CASHOUT,TWD,,20180521,TST-TRD6-SH-CLUBN_006,,F
  TEST_20180521_00066,3000,CASHIN,TWD,20180521,,TST-TRD7-SH-CLUBN_007,,F
  TEST_20180521_00067,3000,CASHOUT,TWD,20180521,20180521,,,E

  Scenario: TC_1: Clear the Taiwan Cash data as a Prerequisite and set up account in DMP

    Given I assign "0001_TW_newcash_Exceptions.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NewCash" to variable "testdata.path"
    And I assign "0001-PortTemplate-TW-attributes_Exceptions.xlsx" to variable "PORTFOLIO_FILENAME"
    And I assign "esi_TW_newcash_outbound_MandatoryMissing" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"

    Given I execute below query to "Clear Taiwan Cash data"
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
      AND ACCT_ALT_ID IN ('TST-TRD1_0001','TST-TRD2_0001','TST-TRD3_0001','TST-TRD4_0001','TST-TRD5_0001','TST-TRD6_0001','TST-TRD7_0001','TST-TRD8_0001','TST-TRD1_0001_RDM','TST-TRD2_0001_RDM','TST-TRD3_0001_RDM','TST-TRD4_0001_RDM','TST-TRD5_0001_RDM','TST-TRD6_0001_RDM','TST-TRD7_0001_RDM','TST-TRD8_0001_RDM')
      AND end_tms IS NULL
    );
    COMMIT
    """

    #As the current portfolio template does not have TWFASID column to set up the code , for the purpose of this test case we are inserting the codes via a sql
    And I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PORTFOLIO_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${PORTFOLIO_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  Scenario: TC_3: Load Taiwan FAS New Cash File and check exceptions in NTEL and EXTR has no entry

    Given I copy files below from local folder "${testdata.path}/testdata/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_TW_FAS_NEW_CASH |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='0'
    """

#    6 exception for missing data in NTEL
    And I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "7":
    """
    SELECT COUNT(*) AS EXCEPTION_ROW_COUNT FROM ft_t_ntel
    WHERE last_chg_trn_id IN
    (SELECT trn_id FROM ft_t_trid WHERE JOB_ID = '${JOB_ID}')
    AND NOTFCN_STAT_TYP='OPEN'
    AND NOTFCN_ID ='60001'
    AND CHAR_VAL_TXT like 'Missing Data Exception%'
    """

    #   Wrong data for Cash_type exception in NTEL
    And I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS EXCEPTION_ROW_COUNT FROM ft_t_ntel
    WHERE last_chg_trn_id IN
    (SELECT trn_id FROM ft_t_trid WHERE JOB_ID = '${JOB_ID}')
    AND NOTFCN_STAT_TYP='OPEN'
    AND MAIN_ENTITY_ID ='TEST_20180521_00060'
    """

    #There is no entry in EXTR TABLE
    And I expect value of column "EXTR_ROW_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS EXTR_ROW_COUNT from ft_t_extr where trn_cde='TWFASCASHTXN' and trd_id in ('TEST_20180521_00060','TEST_20180521_00062','TEST_20180521_00063','TEST_20180521_00064','TEST_20180521_00065','TEST_20180521_00066','TEST_20180521_00067')
    """

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv          |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB |

    Then I expect below files are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |