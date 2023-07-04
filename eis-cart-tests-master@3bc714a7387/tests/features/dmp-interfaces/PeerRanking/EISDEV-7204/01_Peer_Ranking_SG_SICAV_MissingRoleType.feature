#https://jira.pruconnect.net/browse/EISDEV-7204
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 25/11/2020      EISDEV-7204    Peer Ranking  - Include Shareclass roletype for loading Peer rank data
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_7204_ISIN @eisdev_7204 @peer_ranking_dwh @eisdev_7214 @eisdev_7414
Feature: Load SG SICAV Morningstar XLS report with missing role type and verify exceptions

  This is to test if SG SICAV MorningStar Peer Ranking XLS files with missing role type are getting converted to CSV format
  And exception is being raised in DWH

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-7204" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_SICAV_Mtking_Peer_Ranking_ES_ISIN_20201106_SICAV_M_PR_-_All_Funds1_ES_20201106.csv" to variable "OUTPUT_FILENAME_SGSICAV"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    Given I assign "The Account Role AUT OR SECSHRECLS for the Issue Identifier  'ISIN - QSLU51348230' received from EIS could not be retrieved from the GSWAccountIssueRole table" to variable "PERF_PUBLISHING_ERRORMMY"
    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSSGSICAV' AND DW_STATUS_NUM =1 and ACCT_SOK in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='QSLU51348230' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'));
      UPDATE fT_T_wagp SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSSGSICAV' AND ACCT_PRT_PURP_TYP='PRRNKPCT' and dw_Status_num =1 and prnt_wagr_sok in (select wagr_sok from ft_T_wagr where dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='EAA Fund China Equity');
      UPDATE fT_T_wagr SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSSGSICAV' AND dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='EAA Fund China Equity';
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | SICAV Mtking Peer Ranking (ES)_ISIN_20201106.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_SG_SICAV                                       |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                 |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties              |
      | FILEPATTERN             | *.xls                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*SICAV_Mtking_Peer_Ranking*.csv                                |
      | PARALLELISM             | 1                                                                        |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                   |
      | PARAMETERSURI           | db://resource/propertyfiles                                              |
      | SUCCESS_ACTION          | LEAVE                                                                    |
      | LIST_SHEET_NAME         | SICAV M PR - All Funds1 (ES)                                             |
      | REPROCESSPROCESSEDFILES | true                                                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_SGSICAV} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_FAILED_CNT ='17'
    """

  Scenario: Verify if the exception is thrown

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "17":
    """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '60010'
      AND APPL_ID = 'CONCTNS'
      AND PART_ID = 'NESTED'
      AND MSG_SEVERITY_CDE = 40
      AND MAIN_ENTITY_ID LIKE 'QSLU51348230%'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'ISIN:StrtDte:EndDte'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

    And I expect value of column "PERF_LOAD_ERROR" in the below SQL query equals to "${PERF_PUBLISHING_ERRORMMY}":
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
      AND MAIN_ENTITY_ID = 'QSLU51348230::10-31-2020 12:00:00 AM'
      AND MAIN_ENTITY_ID_CTXT_TYP = 'ISIN:StrtDte:EndDte'
    """
