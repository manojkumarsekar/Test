#https://jira.pruconnect.net/browse/EISDEV-7204
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 25/11/2020      EISDEV-7204     Peer Ranking  - Include Shareclass roletype for loading Peer rank data
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_7204 @eisdev_7204_Lookup @peer_ranking_dwh @eisdev_7414
Feature: Load SG SICAV Morningstar XLS report with shareclass roletype lookup and verify details

  This is to test if SG SICAV MorningStar Peer Ranking XLS files are getting converted to CSV format and getting loaded in DWH
  And verify if all records are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-7204" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_SICAV_Mtking_Peer_Ranking_ES_20201106_SICAV_M_PR_-_All_Funds1_ES_20201106.csv" to variable "OUTPUT_FILENAME_SGSICAV1"
    And I assign "Processed_SICAV_Mtking_Peer_Ranking_ES_20201106_SICAV_M_PR_-_All_Funds2_ES_20201106.csv" to variable "OUTPUT_FILENAME_SGSICAV2"
    And I assign "Processed_SICAV_Mtking_Peer_Ranking_ES_20201106_SICAV_M_PR_-_All_Funds3_ES_20201106.csv" to variable "OUTPUT_FILENAME_SGSICAV3"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSSGSICAV' AND DW_STATUS_NUM =1 and ACCT_SOK IN (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id  in ('LU0154355936','LU1857766460','LU1707683964','LU2068974737','LU0326392247','LU0149982760','LU0149983909','LU0795476463','LU1497734951','LU1105988239','LU0315179316','LU0163747925','LU0307460666') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'));
      UPDATE fT_T_wagp SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSSGSICAV' AND ACCT_PRT_PURP_TYP='PRRNKPCT' and dw_Status_num =1 and prnt_wagr_sok in (select wagr_sok from ft_T_wagr where dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC  in ('EAA Fund Asia ex-Japan Equity','EAA Fund China Equity','EAA Fund USD Corporate Bond','EAA Fund Asia Bond','EAA Fund Other Equity'));
      UPDATE fT_T_wagr SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSSGSICAV' AND dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC  in ('EAA Fund Asia ex-Japan Equity','EAA Fund China Equity','EAA Fund USD Corporate Bond','EAA Fund Asia Bond','EAA Fund Other Equity');
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | SICAV Mtking Peer Ranking (ES)_20201106.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi               |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_SG_SICAV                                                     |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                               |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties                            |
      | FILEPATTERN             | *.xls                                                                                  |
      | LOAD_FILE_PATTERNS      | Processed_*SICAV_Mtking_Peer_Ranking*.csv                                              |
      | PARALLELISM             | 1                                                                                      |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                                 |
      | PARAMETERSURI           | db://resource/propertyfiles                                                            |
      | SUCCESS_ACTION          | LEAVE                                                                                  |
      | LIST_SHEET_NAME         | SICAV M PR - All Funds1 (ES),SICAV M PR - All Funds2 (ES),SICAV M PR - All Funds3 (ES) |
      | REPROCESSPROCESSEDFILES | true                                                                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_SGSICAV1} |
      | ${OUTPUT_FILENAME_SGSICAV2} |
      | ${OUTPUT_FILENAME_SGSICAV3} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "TASK_SUCCESS_CNT" in the below SQL query equals to "221":
    """
       select sum(TASK_SUCCESS_CNT) TASK_SUCCESS_CNT from ft_T_jblg where prnt_job_id in (select prnt_job_id from fT_T_jblg where job_id ='${JOB_ID}')
    """

  Scenario: Perform checks in WAGR for checking load scenario

    Then I expect value of column "WAGR_COUNT" in the below SQL query equals to "5":
    """
      SELECT COUNT(*) AS WAGR_COUNT FROM FT_T_WAGR
      WHERE DATA_SRC_ID = 'MSSGSICAV' AND dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC in ('EAA Fund Asia ex-Japan Equity','EAA Fund China Equity','EAA Fund USD Corporate Bond','EAA Fund Asia Bond','EAA Fund Other Equity')
    """

  Scenario: Perform checks in WAGP for checking load scenario

    Then I expect value of column "WAGP_COUNT" in the below SQL query equals to "13":
    """
      SELECT COUNT(*) AS WAGP_COUNT FROM FT_T_WAGP
      WHERE DATA_SRC_ID = 'MSSGSICAV' AND ACCT_PRT_PURP_TYP='PRRNKPCT' and dw_Status_num =1 and prnt_wagr_sok in (select wagr_sok from ft_T_wagr where dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC  in ('EAA Fund Asia ex-Japan Equity','EAA Fund China Equity','EAA Fund USD Corporate Bond','EAA Fund Asia Bond','EAA Fund Other Equity'))
    """

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "221":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSSGSICAV' AND DW_STATUS_NUM =1 and ACCT_SOK in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('LU0154355936','LU1857766460','LU1707683964','LU2068974737','LU0326392247','LU0149982760','LU0149983909','LU0795476463','LU1497734951','LU1105988239','LU0315179316','LU0163747925','LU0307460666') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """
