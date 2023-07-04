#https://jira.pruconnect.net/browse/EISDEV-7249
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-KORLBU

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 10/12/2020      EISDEV-7249    DWH | Peer Ranking | Excel to CSV conversion fails for Peer ranking file load Details
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_7249_XLSX @eisdev_7249 @peer_ranking_dwh @eisdev_7414
Feature: Load KOR LBU XLSX report with missing data and verify details

  This is to test if KOR LBU Peer Ranking XLSX files are getting converted to CSV format and getting loaded in DWH

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-7249" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Peer_group_rankingE_Load__20200831_Equity.csv" to variable "OUTPUT_FILENAME_KORLBU"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSKORLBU' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655');
      UPDATE FT_T_WACT set INTRNL_ID11='QSLU51346655' WHERE acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='QSLU51346655'  and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_Status_num=1 and ACCT_STAT_TYP='OPEN';
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Peer group ranking(E) Load _20200831.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_LBU                                         |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Peer_group_ranking*.csv                                        |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Equity                                                                    |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_KORLBU} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSKORLBU' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')
    """