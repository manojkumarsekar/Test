#https://jira.pruconnect.net/browse/EISDEV-7233
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-KORPER

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 02/09/2020      EISDEV-7233    DWH |  Peer Ranking | KOR Performance load fails when no BL1PRIM BM  set
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_7233_XLS @eisdev_7233 @peer_ranking_dwh @eisdev_7414
Feature: Load KOR PER XLSX report with missing primary benchmark and verify exceptions

  This is to test if KOR PER Peer Ranking XLSX files with missing primary benchmark are getting converted to CSV format
  And exception is being raised in DWH

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-7233" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Load_Fund_performance_as_of_202008_Report.csv" to variable "OUTPUT_FILENAME_KORPER"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    Given I assign "The Account/Benchmark Role PRIMARY for the Account Alternate Identifier  'PORTFOLIOISIN - QSLU51346655' received from EIS could not be retrieved from the WACKGSWAccountAccountRole table" to variable "PERF_PUBLISHING_ERROR"
    And I execute below query
    """
         UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSKORPER' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655');
         UPDATE FT_T_WACT set INTRNL_ID11='QSLU51346655' WHERE acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='QSLU51346655'  and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_Status_num=1 and ACCT_STAT_TYP='OPEN';
         UPDATE FT_T_WACR SET dw_status_num =0  WHERE rl_typ ='PRIMARY' AND acct_sok IN (SELECT w.acct_sok FROM ft_T_wact w WHERE INTRNL_ID11='QSLU51346655' AND DW_STATUS_NUM=1);
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Load Fund performance as of 202008.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_PER                                         |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Fund_performance_as_of*.csv                                    |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Report                                                                    |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_KORPER} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_FAILED_CNT ='1'
    """

  Scenario: Verify if the exception is thrown

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60008'
      AND APPL_ID = 'CONCTNS'
      AND PART_ID = 'NESTED'
      AND MSG_SEVERITY_CDE = 40
      AND MAIN_ENTITY_ID LIKE 'QSLU51346655:08-31-2020 12:00:00 AM%'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'ISIN:Value Date'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

    And I expect value of column "PERF_LOAD_ERROR" in the below SQL query equals to "${PERF_PUBLISHING_ERROR}":
    """
      SELECT CHAR_VAL_TXT AS PERF_LOAD_ERROR FROM FT_T_NTEL
      WHERE LAST_CHG_TRN_ID IN
        (SELECT TRN_ID FROM FT_T_TRID
        WHERE JOB_ID ='${JOB_ID}')
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_CNT = '1'
      AND APPL_ID = 'CONCTNS'
      AND PART_ID = 'NESTED'
      AND MSG_SEVERITY_CDE = 40
      AND MAIN_ENTITY_ID = 'QSLU51346655:08-31-2020 12:00:00 AM'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'ISIN:Value Date'
    """

  Scenario: Reset primary benchmark relationship to old value

    And I execute below query
    """
         UPDATE FT_T_WACR SET dw_status_num =1  WHERE rl_typ ='PRIMARY' AND acct_sok IN (SELECT w.acct_sok FROM ft_T_wact w WHERE INTRNL_ID11='QSLU51346655' AND DW_STATUS_NUM=1);
    """
