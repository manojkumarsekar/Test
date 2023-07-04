#https://collaborate.intranet.asia/pages/viewpage.action?pageId=50477728
# https://jira.intranet.asia/browse/TOM-4109
#https://jira.intranet.asia/browse/TOM-4264 : Added new field RECIPIENT in File 46
#TOM-4287 : Run report prior to tests, to ensure test publishing only refers to trades loaded and not trades from prod refresh
#https://jira.intranet.asia/browse/TOM-4400 : File 46 enhanced to add SSB Fund admin sent status to BRS
# Tom-4469:Regression Failuree For Trade_Nack_AckToBRS Feature File after change done in wrapper-Fix provided for these
# Tom-4426:Workflow changes for FundApps Publishing Wrapper Workflow- XmlMergeLevel Parameter

@gc_interface_trades @gc_interface_transactions
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4109 @tom_4109_tradeacknack @tom_4264 @tom_4287 @tom_4294 @tom_4400 @tom_4426 @tom_4469 @4537
Feature: Test Publish Trade ACK NACK To BRS

  Scenario: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNACK_ACKToBRS" to variable "testdata.path"
    And I execute below query and extract values of "CRTS_FUND_CODE;BRS_FUND_CODE" into same variables
    """
    SELECT c.acct_alt_id AS CRTS_FUND_CODE, b.acct_alt_id AS BRS_FUND_CODE
    FROM   ft_t_acid c, ft_t_acid b
    WHERE  c.acct_id_ctxt_typ = 'CRTSID' AND c.end_tms IS NULL AND c.acct_alt_id LIKE 'TT%'
    AND    b.acct_id = c.acct_id AND b.acct_id_ctxt_typ = 'BRSFUNDID' AND b.end_tms IS NULL
    AND    ROWNUM = 1 AND NOT EXISTS
	(SELECT 1 FROM FT_T_ACGP ACGP,FT_T_ACGR ACGR WHERE ACGP.ACCT_ID = C.ACCT_ID
	AND ACGP.PRNT_ACCT_GRP_OID = ACGR.ACCT_GRP_OID AND ACGR.END_TMS IS NULL
	AND ACGP.END_TMS IS NULL AND ACGR.ACCT_GRP_ID = 'TWFACAP1')
    """

    And I execute below query and extract values of "CRTS_FUND_CODE_TWFACAP1;BRS_FUND_CODE_TWFACAP1" into same variables
    """
    SELECT c.acct_alt_id AS CRTS_FUND_CODE_TWFACAP1, b.acct_alt_id AS BRS_FUND_CODE_TWFACAP1
    FROM   ft_t_acid c, ft_t_acid b
    WHERE  c.acct_id_ctxt_typ = 'CRTSID' AND c.end_tms IS NULL AND c.acct_alt_id LIKE 'TT%' and c.acct_alt_id<>'${CRTS_FUND_CODE}'
    AND    b.acct_id = c.acct_id AND b.acct_id_ctxt_typ = 'BRSFUNDID' AND b.end_tms IS NULL
    AND    ROWNUM = 1
    """

    And I execute below query
    """
    ${testdata.path}/sql/SetUp_ACGR_ACGP_FRAP.sql
    """

    And I execute below query
    """
    UPDATE FT_T_EXTR SET END_TMS = SYSDATE WHERE TRD_ID IN ('${BRS_FUND_CODE}-401','${BRS_FUND_CODE}-402','${BRS_FUND_CODE}-403','${BRS_FUND_CODE}-404','${BRS_FUND_CODE_TWFACAP1}-405')  AND END_TMS IS NULL;
    UPDATE FT_T_ETID SET END_TMS = SYSDATE WHERE EXEC_TRN_ID IN ('${BRS_FUND_CODE}-401','${BRS_FUND_CODE}-402','${BRS_FUND_CODE}-403','${BRS_FUND_CODE}-404','${BRS_FUND_CODE_TWFACAP1}-405') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

  Scenario: Clear any residual prod copy trades ack/nacks by running the report once

    Given I assign "ack_nack_out_file" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml        |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_TRADE_ACK_NACK_SUB |
      | UNESCAPE_XML         | true                               |

  Scenario: Load Trades files

  INVNUM=-401 cancel trade with mandatory field TRADE_SETTLEDATE missing to get exception - NACK will be sent trade is not created
  INVNUM=-402 trade with incorrect domain value for TRD_SETTLE_LOCATION missing to get exception of severity 40 - for this ACK will be sent as only one segment failed
  INVNUM=-403 executed trade (TRD_TRADER populated and TRD_REVIEWED_BY empty) (cancel status) - ACK will be sent
  INVNUM=-404 confirmed trade (TRD_TRADER populated and TRD_REVIEWED_BY populated) - ACK will be sent
  INVNUM=-405 reviewed trade sent to SSB fund admin - ACK for sent to fundadmin will be sent

    Given I assign "001_tradefile.xml" to variable "INPUT_FILENAME"
    Given I create input file "${INPUT_FILENAME}" using template "001_tradefile_template.xml" from location "${testdata.path}/infiles"
    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_TOT_CNT = 5
      AND TASK_CMPLTD_CNT = 5
      """

    And I pause for 30 seconds

  Scenario: Publish trade recap file for SSB

    Given I assign "traderecap_ssb_out_file" to variable "PUBLISHING_FILE_NAME_RECAP"
    And I assign "/dmp/out/ssb" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME_RECAP}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISHING_FILE_NAME_RECAP}.csv |
      | SUBSCRIPTION_NAME           | EITW_DMP_TO_SSB_TRADEFLOW_B1      |
      | EXTRACT_STREETREF_TO_SUBMIT | true                              |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME_RECAP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_RECAP}_${VAR_SYSDATE}_1.csv |

  Scenario: Verify trade status

    And I expect value of column "EXST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_ROW_COUNT FROM FT_T_EXST
      WHERE EXEC_TRD_STAT_TYP = 'SENT' AND GEN_CNT = 1
      AND DATA_SRC_ID = 'SSB'
      AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID in ('${BRS_FUND_CODE_TWFACAP1}-405') AND  END_TMS IS NULL
      )
      """

  Scenario: Publish acknack file for trade

    Given I assign "ack_nack_out_file" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/intraday" to variable "publishDirectory"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${publishDirectory}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml        |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_TRADE_ACK_NACK_SUB |
      | UNESCAPE_XML         | true                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${publishDirectory}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "${publishDirectory}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

  Scenario: Verify trade ACK NACK file

    Given I create input file "TradeNACKExpected.xml" using template "TradeNACKTemplate.xml" from location "${testdata.path}/outfiles"
    Then I expect reconciliation between generated XML file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" and reference XML file "${testdata.path}/outfiles/testdata/TradeNACKExpected.xml" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_001nack_exceptions.xml" file