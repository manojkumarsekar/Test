#https://jira.pruconnect.net/browse/EISDEV-6851
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-goals

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 02/09/2020      EISDEV-6851    Peer rank data- JP Unit Trust Morningstar report
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_6851_XLSX @eisdev_6851 @peer_ranking_dwh @eisdev_7414
Feature: Load and Update JP Unit Trust Morningstar XLSX report and verify details

  This is to test if JP Unit Trust MorningStar Peer Ranking XLSX files are getting converted to CSV format and getting loaded in DWH
  And verify if various columns are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-6851" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Performance_Comparison_JP_Load_20200915_Local_PR-JP_20200915.csv" to variable "OUTPUT_FILENAME_LOCALPRJP"
    And I assign "Processed_Performance_Comparison_JP_Update_20200915_Local_PR-JP_20200915.csv" to variable "OUTPUT_FILENAME_UPDATE_LOCALPRJP"
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
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSJPUT' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT');
      UPDATE fT_T_wagp SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSJPUT' AND ACCT_PRT_PURP_TYP='PRRNKPCT' and dw_Status_num =1 and prnt_wagr_sok in (select wagr_sok from ft_T_wagr where dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='Japan Fund Japan Small/Mid-Cap Value Equity');
      UPDATE fT_T_wagr SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') where DATA_SRC_ID = 'MSJPUT' AND dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='Japan Fund Japan Small/Mid-Cap Value Equity';
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Performance Comparison_JP_Load_20200915.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_JP_UT                                           |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Local_PR-JP*.csv                                               |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Local PR-JP                                                               |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_LOCALPRJP} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WAGR for checking load scenario

    Then I expect value of column "WAGR_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WAGR_COUNT FROM FT_T_WAGR
      WHERE DATA_SRC_ID = 'MSJPUT' AND dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='Japan Fund Japan Small/Mid-Cap Value Equity'
    """

  Scenario: Perform checks in WAGP for checking load scenario

    Then I expect value of column "WAGP_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WAGP_COUNT FROM FT_T_WAGP
      WHERE DATA_SRC_ID = 'MSJPUT' AND ACCT_PRT_PURP_TYP='PRRNKPCT' and dw_Status_num =1 and prnt_wagr_sok in (select wagr_sok from ft_T_wagr where dw_Status_num =1 and ACCT_GRP_PURP_TYP='PRRNKGR' and ACCT_GRP_DESC ='Japan Fund Japan Small/Mid-Cap Value Equity')
    """

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSJPUT' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                                   | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | GroupInvestment                          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GroupInvestment  from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_2='Eastspring Japan M/S Cap Sel Value Eq Fd'       |
      | RegionofSale                             | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS RegionofSale from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_6='Japan'                                              |
      | FirmName                                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FirmName from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_5='Eastspring Investments Limited'                         |
      | ReturnDate                               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnDate from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and trunc(w.adjst_tms)=to_date('11-09-2020','DD-MM-YYYY')                       |
      | AsOfDate                                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AsOfDate from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and trunc(w.as_of_tms)=to_date('31-08-2020','DD-MM-YYYY')                         |
      | ISIN                                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISIN from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_3='TW000T0716Y8'                                               |
      | Netshare                                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Netshare from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_VAL_CAMT_1='23.188269'                                                  |
      | MorningstarCategory                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MorningstarCategory from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_4='Japan Fund Japan Small/Mid-Cap Value Equity' |

      | ReturnCumulative1Month                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative1Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RETURN_1M_CAMT='11.90033'                                     |
      | PeerGroupRank1Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='1'                                          |
      | PeerGroupQuartile1Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_1M_PGRP_QRTL_NUM='2'                                     |
      | Noofinvestmentsrankedinpeergroup1Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_1M_PGRP_PART_NUM='3'                      |

      | ReturnCumulative3Month                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative3Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RETURN_3M_CAMT='-0.815822'                                    |
      | PeerGroupRank3Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_3M_PGRP_RNK_NUM='4'                                          |
      | PeerGroupQuartile3Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_3M_PGRP_QRTL_NUM='5'                                     |
      | Noofinvestmentsrankedinpeergroup3Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_3M_PGRP_PART_NUM='6'                      |

      | ReturnCumulative6Month                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative6Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RETURN_6M_CAMT='-2.864989'                                    |
      | PeerGroupRank6Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank6Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_6M_PGRP_RNK_NUM='7'                                          |
      | PeerGroupQuartile6Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile6Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_6M_PGRP_QRTL_NUM='8'                                     |
      | Noofinvestmentsrankedinpeergroup6Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup6Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RET_6M_PGRP_PART_NUM='9'                      |

      | ReturnCumulativeYTDMonth                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulativeYTDMonth from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.YTD_RETURN_CAMT='-20.91465'                                 |
      | PeerGroupRankYTDMonth                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRankYTDMonth from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.YTD_RET_PGRP_RNK_NUM='10'                                      |
      | PeerGroupQuartileYTDMonth                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartileYTDMonth from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.YTD_RET_PGRP_QRTL_NUM='11'                                 |
      | NoofinvestmentsrankedinpeergroupYTDMonth | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NoofinvestmentsrankedinpeergroupYTDMonth from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.YTD_RET_PGRP_PART_NUM='12'                  |

      | ReturnCumulative1Yr                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative1Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.CUM_1YR_RETURN_CAMT='-4.898863'                                  |
      | PeerGroupRank1Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='13'                                        |
      | PeerGroupQuartile1Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_QRTL_NUM='14'                                   |
      | Noofinvestmentsrankedinpeergroup1Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PART_NUM='15'                    |

      | ReturnCumulative3Yr                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative3Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_3YR_RETURN_CAMT='-8.134976'                                   |
      | PeerGroupRank3Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_RNK_NUM='16'                                         |
      | PeerGroupQuartile3Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_QRTL_NUM='17'                                    |
      | Noofinvestmentsrankedinpeergroup3Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_PART_NUM='18'                     |

      | ReturnCumulative5Yr                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative5Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_5YR_RETURN_CAMT='-0.278484'                                   |
      | PeerGroupRank5Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank5Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_5Y_RET_PGRP_RNK_NUM='19'                                         |
      | PeerGroupQuartile5Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile5Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_5Y_RET_PGRP_QRTL_NUM='20'                                    |
      | Noofinvestmentsrankedinpeergroup5Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup5Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.AN_5Y_RET_PGRP_PART_NUM='21'                     |

  Scenario: Remove files already present in directory before running update scenario

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Run Excel to CSV Peer Ranking workflow for update file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Performance Comparison_JP_Update_20200915.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_JP_UT                                           |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Local_PR-JP*.csv                                               |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Local PR-JP                                                               |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_UPDATE_LOCALPRJP} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking update scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSJPUT' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                 | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | ReturnCumulative1Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative1Month from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.RETURN_1M_CAMT='12.90033' |
      | PeerGroupRank1Yr       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Yr from ft_w_wcri w where data_src_id = 'MSJPUT' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in ((select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0716Y8' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='2'     |