#https://jira.pruconnect.net/browse/EISDEV-6964
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-KORLBU

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 02/09/2020      EISDEV-6964    Peer rank data- KOR LBU report
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_6964_XLS @eisdev_6964 @peer_ranking_dwh @eisdev_7414
Feature: Load and Update KOR LBU XLS report and verify details

  This is to test if KOR LBU Peer Ranking XLS files are getting converted to CSV format and getting loaded in DWH
  And verify if various columns are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-6964" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Peer_group_rankingE_Load__20200831_Equity.csv" to variable "OUTPUT_FILENAME_KORLBU"
    And I assign "Processed_Peer_group_rankingE_Update__20200831_Equity.csv" to variable "OUTPUT_FILENAME_UPDATE_KORLBU"
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
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSKORLBU' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655');
      UPDATE FT_T_WACT set INTRNL_ID11='QSLU51346655' WHERE acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='QSLU51346655'  and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_Status_num=1 and ACCT_STAT_TYP='OPEN';
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Peer group ranking(E) Load _20200831.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_LBU                                        |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                 |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties              |
      | FILEPATTERN             | *.xls                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Peer_group_ranking*.csv                                       |
      | PARALLELISM             | 1                                                                        |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                   |
      | PARAMETERSURI           | db://resource/propertyfiles                                              |
      | SUCCESS_ACTION          | LEAVE                                                                    |
      | LIST_SHEET_NAME         | Equity                                                                   |
      | REPROCESSPROCESSEDFILES | true                                                                     |

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

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                    | Query                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | GroupInvestment           | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GroupInvestment  from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_2='Eastspring Investments Korea Leaders Securities Baby Investment Trust[Equity]' |
      | AsOfDate                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AsOfDate from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and trunc(w.as_of_tms)=to_date('31-08-2020','DD-MM-YYYY')                                                        |
      | FirmName                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FirmName from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_5='Eastspring Investments'                                                                |
      | ISIN                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISIN from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_3='QSLU51346655'                                                                              |

      | PeerGroupRank1Month       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='1'                                                                         |
      | PeerGroupQuartile1Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_1M_PGRP_QRTL_NUM='2'                                                                    |

      | PeerGroupRank3Month       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_3M_PGRP_RNK_NUM='4'                                                                         |
      | PeerGroupQuartile3Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_3M_PGRP_QRTL_NUM='5'                                                                    |

      | PeerGroupRank6Month       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank6Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_6M_PGRP_RNK_NUM='7'                                                                         |
      | PeerGroupQuartile6Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile6Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_6M_PGRP_QRTL_NUM='8'                                                                    |

      | PeerGroupRankYTDMonth     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRankYTDMonth from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_RET_PGRP_RNK_NUM='10'                                                                     |
      | PeerGroupQuartileYTDMonth | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartileYTDMonth from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_RET_PGRP_QRTL_NUM='11'                                                                |

      | PeerGroupRank1Yr          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Yr from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='13'                                                                       |
      | PeerGroupQuartile1Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Yr from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_QRTL_NUM='14'                                                                  |

      | PeerGroupRank3Yr          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Yr from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_RNK_NUM='16'                                                                        |
      | PeerGroupQuartile3Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Yr from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_QRTL_NUM='17'                                                                   |

      | PeerGroupRank1Week        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Week from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_VAL_CAMT_33='18'                                                                             |
      | PeerGroupQuartile1Week    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Week from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_VAL_CAMT_34='19'                                                                         |

  Scenario: Remove files already present in directory before running update scenario

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Run Excel to CSV Peer Ranking workflow for update file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Peer group ranking(E) Update _20200831.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_LBU                                        |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                 |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties              |
      | FILEPATTERN             | *.xls                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Peer_group_ranking*.csv                                       |
      | PARALLELISM             | 1                                                                        |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                   |
      | PARAMETERSURI           | db://resource/propertyfiles                                              |
      | SUCCESS_ACTION          | LEAVE                                                                    |
      | LIST_SHEET_NAME         | Equity                                                                   |
      | REPROCESSPROCESSEDFILES | true                                                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_UPDATE_KORLBU} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking update scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSKORLBU' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column               | Query                                                                                                                                                                                                                                                                                                                                                          |
      | PeerGroupRank1Month  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Month from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='12'       |
      | PeerGroupQuartile1Yr | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Yr from ft_w_wcri w where data_src_id = 'MSKORLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_QRTL_NUM='21' |
