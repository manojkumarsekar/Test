#https://jira.intranet.asia/browse/TOM-4095
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=Taiwan+-+Generate+Settlement+Instructions+Outbound+File
#https://jira.intranet.asia/browse/TOM-4476 - Feature files enhancement to make it generalized

@dmp_regression_unittest
@tom_4095 @tom_4095_003_noaoilfieldchange @tom_4476 @tw_settlement_instruction_format
@eisdev_7439

Feature: Test SSI report for no AOIL field change

  Scenario: Clear table data and setup variables
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"

    And I execute below query
    """
   ${testdata.path}/sql/InsertAccount.sql
    """

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('4267-SITEST3') AND END_TMS IS NULL;
     COMMIT
    """

    And I execute below query
    """
    UPDATE FT_T_ETID SET END_TMS = SYSDATE
    WHERE EXEC_TRN_ID IN ('4267-SITEST3')
    AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """


  Scenario: Load portfolio, security, broker and trade file

    Given I assign "sm.xml" to variable "INPUT_FILENAME1"
    And I assign "broker.xml" to variable "INPUT_FILENAME2"
    And I assign "003_new_trade_CIS.xml" to variable "INPUT_FILENAME3"
    And I assign "PortfolioTemplate.xlsx" to variable "INPUT_FILENAME4"
    And I assign "/dmp/out/taiwan/settlement" to variable "PUBLISHING_DIR"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |
      | ${INPUT_FILENAME4} |


    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME3}" with tagName "ISIN" to variable "ISIN"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME3}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${ISIN}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN}'"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf.error |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME4}                   |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    Then I extract new job id from jblg table into a variable "JOB_ID4"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME2}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |

    Then I extract new job id from jblg table into a variable "JOB_ID2"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME1}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"


    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME3}              |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID3"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID1}' and TASK_SUCCESS_CNT ='1'
      """


    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID2}' and TASK_SUCCESS_CNT ='1'
      """


    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID3}' and TASK_SUCCESS_CNT ='1'
      """

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID4}' and TASK_SUCCESS_CNT ='3'
      """

    # Verfication
    And I expect value of column "SEC_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) SEC_ROW_COUNT from ft_t_isid where iss_id ='Y1434TCB7' and end_tms is null
      """

    And I expect value of column "BROKER_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) BROKER_ROW_COUNT from ft_t_FIID where fins_id ='TEST_SI' and end_tms is null
      """

    And I expect value of column "TRANS_ROW_COUNT" in the below SQL query equals to "1":
    """
      select count(*) TRANS_ROW_COUNT from ft_t_extr where trd_id ='4267-SITEST3' and end_tms is null
      """

    # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4267-SITEST3' AND  END_TMS IS NULL
      )
      """

    #waiting intentionally
    And I pause for 10 seconds

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |


    #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWSENT'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4267-SITEST3' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/taiwan/settlement" after processing:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" after processing:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf.error |

           #waiting intentionally
    And I pause for 10 seconds

  Scenario:  Load Trades file after changing AOIL field - TRD_SETTLE_LOCATION (STL_LOC_MNEM)

    Given I assign "003_AOIL_nofield_change_CIS.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "ISIN" to variable "ISIN"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 14022019_${PORTFOLIOCRTSID}_FUND_OPEN_END_*_NEWM*.pdf.error |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

         # Check if TRDSETTLELOC is loaded successfully
    And I expect value of column "EXIN_LOC_CNT" in the below SQL query equals to "1":
    """
       select COUNT(*) AS EXIN_LOC_CNT from ft_T_exin
       where STL_LOC_MNEM = (Select STL_LOC_MNEM from ft_T_sloc where STL_LOC_TYP = 'PTC' AND END_TMS IS NULL)
       AND TRN_PROC_INSTRUC_TYP = 'TRDSETTLELOC'
       AND EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
       WHERE TRD_ID = '4267-SITEST3' AND  END_TMS IS NULL)
      """

      # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '4267-SITEST3' AND  END_TMS IS NULL
      )
      """

   #waiting intentionally
    And I pause for 10 seconds


  Scenario: Run publish document workflow for trade after changing AOIL field

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}               |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |


       #Verify if PUB1 entry is updated succesfully
    Then I expect value of column "NOROWPUB1COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS NOROWPUB1COUNT FROM FT_CFG_PUB1
    WHERE  PUB_STATUS = 'CLOSED'
    AND PUB_DESCRIPTION='No rows found by the publishing query'
    AND  PUB_CNT =0
    AND START_TMS > (SELECT START_TMS
    FROM (SELECT pub1.START_TMS, row_number() OVER (ORDER BY START_tMS DESC) rnum
          FROM FT_CFG_PUB1 pub1)
          WHERE rnum = 2)
    """
