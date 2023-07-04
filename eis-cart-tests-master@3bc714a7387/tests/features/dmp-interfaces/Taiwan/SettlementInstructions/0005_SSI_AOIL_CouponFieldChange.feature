#https://jira.intranet.asia/browse/TOM-4095
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=Taiwan+-+Generate+Settlement+Instructions+Outbound+File

#@tom_4095_005_couponaoilfieldchange @tobecompletedafterrequirementclarification
Feature: Test SSI report for one AOIL field change - To be complated after requirement clarification

  Scenario:  Load security file

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/SettlementInstructions" to variable "testdata.path"

    Given I assign "005_brssecurity.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME}" with tagName "ISIN" to variable "ISIN"

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISS_ID}','${BCUSIP}','${ISIN}'"

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |


    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Clear table data and setup variables

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('3539-306') AND END_TMS IS NULL;
     COMMIT
    """

    And I execute below query
    """
    UPDATE FT_T_ETID SET END_TMS = SYSDATE
    WHERE EXEC_TRN_ID IN ('3539-306') AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

  Scenario:  Load Trades file for new fund Local security transaction in portfolio TT56 (INVNUM=-306)

    Given I assign "005_new_trade_CIS.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME}" with tagName "ISIN" to variable "ISIN"
    Then I extract value from the xml file "${testdata.path}/infiles/${INPUT_FILENAME}" with tagName "PORTFOLIOS_PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf.error |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3539-306' AND  END_TMS IS NULL
      )
      """
       #waiting intentionally
    And I pause for 30 seconds

  Scenario: Run publish document workflow for trade

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}             |
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
      WHERE TRD_ID = '3539-306' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/taiwan/settlement" after processing:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" after processing:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf.error |

  Scenario:  Load security file for changing AOIL field - TRD_COUPON

    Given I assign "005_AOIL_couponfield_change_security.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" if exists:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf.error |


    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |


    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and   JOB_STAT_TYP ='CLOSED'
      """

      #Check if COUPON AMOUUNT is changed succesfully
    And I expect value of column "BDST_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BDST_ROW_COUNT FROM FT_T_BDST
      WHERE INSTR_ID IN ( SELECT INSTR_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3539-306' AND  END_TMS IS NULL)
      AND STATS_CURR_CDE = 'USD'  AND CRRNT_ISS_CAMT = 800000000
      """

      # Check if EXST is created with data present in the test file (TRD_STATUS, TOUCH_COUNT )
    And I expect value of column "EXST_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXST_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'NEWM'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'BRS')
      AND EXST.DATA_SRC_ID = 'BRS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3539-306' AND  END_TMS IS NULL
      )
      """
       #waiting intentionally
    And I pause for 30 seconds

  Scenario: Run publish document workflow for trade after changing AOIL field

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_MAINCUST_SI_SUB_AOI      |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.ssi.WORKFLOW.url}             |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveSSIStatus                   |

    #Verify Data
    Then I expect value of column "EXST_EIS_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS EXST_EIS_PROCESSED_ROW_COUNT FROM FT_T_EXST EXST
      WHERE EXST.EXEC_TRD_STAT_TYP = 'REVSENT'
      AND EXST.GEN_CNT = (SELECT MAX (GEN_CNT) FROM FT_T_EXST EXST1 WHERE EXST1.EXEC_TRD_ID = EXST.EXEC_TRD_ID AND EXST1.DATA_SRC_ID= 'EIS')
      AND EXST.DATA_SRC_ID = 'EIS'
      AND EXST.EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID = '3539-306' AND  END_TMS IS NULL
      )
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "/dmp/out/taiwan/settlement" after processing:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "/dmp/out/taiwan/settlement" after processing:
      | 3539-306_${PORTFOLIOCRTSID}_${ISIN}_*_NEWM_*.pdf.error |
