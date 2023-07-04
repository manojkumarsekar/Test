#https://jira.pruconnect.net/browse/EISDEV-7529
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISPRM&title=Taiwan+peer+rank
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-goalsg

# ===================================================================================================================================================================================
# Date            JIRA            Comments
# ===================================================================================================================================================================================
# 26/04/2021      EISDEV-7529     Peer rank data - TW LBU report
# 04/05/2021      EISDEV-7573     Expand scope of peer rank that are loaded into DWH - TW (including all worksheets)
# ===================================================================================================================================================================================

@dw_interface_peer_ranking @dmp_dw_regression @ignore @to_be_fixed_eisdev_7619
@eisdev_7529_XLS @eisdev_7529 @peer_ranking_dwh @eisdev_7573
Feature: Load and Update TW LBU XLS report and verify details

  This is to test if TW LBU Peer Ranking XLS files are getting converted to CSV format and getting loaded in DWH
  And verify if various columns are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/TaiwanLBU" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_India_Eq_Fund_Customised_20210309.csv" to variable "OUTPUT_FILENAME_TWLBU_INDIA"
    And I assign "Processed_Taiwan_Peer_Ranking_Report_Update_20210309_TW_India_Eq_Fund_Customised_20210309.csv" to variable "OUTPUT_FILENAME_UPDATE_TWLBU"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
            where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0761C0' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0718Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0730A9' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0732Y5' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0739Y0' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0736Y6' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0727Y5' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('LU0127657111','TW000T0716Y8') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0712Y7' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0711Y9' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('TW000T0759H3','TW000T0722Y6') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0737A4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0728Y3' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('TW000T0705Y1','TW000T0708Y5') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0704Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS')
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0717Y6' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Taiwan Peer Ranking Report Load_20210309.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_TW_LBU                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | FILEPATTERN             | *Taiwan*.xls                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | LOAD_FILE_PATTERNS      | Processed_*Taiwan*.csv                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | PARALLELISM             | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | SUCCESS_ACTION          | LEAVE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | LIST_SHEET_NAME         | TW Balance Fund,TW E-Tech Fund and High Tech Fu,TW Export Fund and Essence Fund,TW Global Bond FOF,TW Global Equity FOF,TW Global High Yield Bond Fund,TW QQ Fund,TW Small Capital Fund,TW Well Pool MM Fund,TW European Fund Customised,TW Asia Pac HY Fund Customised,TW Brazil Eq Fund Customised,TW China Eq Fund Customised,TW Asia Pac Infra Fund Customis,TW Asia Pac REITs Fund Customis,TW US High Tech Fund Customised,TW Glb Green Fund Customised,TW India Eq Fund Customised |
      | REPROCESSPROCESSEDFILES | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_TWLBU_INDIA} |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Glb_Green_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_US_High_Tech_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Asia_Pac_REITs_Fund_Customis_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_China_Eq_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Asia_Pac_Infra_Fund_Customis_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Asia_Pac_HY_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Brazil_Eq_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_European_Fund_Customised_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Well_Pool_MM_Fund_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Small_Capital_Fund_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_QQ_Fund_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Global_High_Yield_Bond_Fund_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Global_Equity_FOF_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Global_Bond_FOF_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Export_Fund_and_Essence_Fund_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_E-Tech_Fund_and_High_Tech_Fu_20210309.csv |
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | Processed_Taiwan_Peer_Ranking_Report_Load_20210309_TW_Balance_Fund_20210309.csv |

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT_INDIA_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_INDIA_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_GLB_GREEN_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_GLB_GREEN_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0761C0' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_US_HIGH_TECH_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_US_HIGH_TECH_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0718Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_ASIA_PAC_REITS_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_ASIA_PAC_REITS_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0730A9' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    Then I expect value of column "WCRI_COUNT_ASIA_PAC_INFRA_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_ASIA_PAC_INFRA_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0732Y5' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_CHINA_EQ_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_CHINA_EQ_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0739Y0' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    Then I expect value of column "WCRI_COUNT_BRAZIL_EQ_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_BRAZIL_EQ_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0736Y6' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_ASIA_PAC_HY_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_ASIA_PAC_HY_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0727Y5' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

    Then I expect value of column "WCRI_COUNT_EUROPEAN_FUND" in the below SQL query equals to "2":
    """
      select count(*) as WCRI_COUNT_EUROPEAN_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('LU0127657111','TW000T0716Y8') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    Then I expect value of column "WCRI_COUNT_WELL_POOL_MM_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_WELL_POOL_MM_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0712Y7' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_SMALL_CAPITAL_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_SMALL_CAPITAL_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0711Y9' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_QQ_FUND" in the below SQL query equals to "2":
    """
      select count(*) as WCRI_COUNT_QQ_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('TW000T0759H3','TW000T0722Y6') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    Then I expect value of column "WCRI_COUNT_GLOBAL_HIGH_BOND_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_GLOBAL_HIGH_BOND_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0737A4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_GLOBAL_BOND_FOF_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_GLOBAL_BOND_FOF_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0728Y3' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_EXPORT_FUND_ESSENCE_FUND" in the below SQL query equals to "2":
    """
      select count(*) as WCRI_COUNT_EXPORT_FUND_ESSENCE_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id in ('TW000T0705Y1','TW000T0708Y5') and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP in ('AUT','SECSHRECLS'))
    """

    Then I expect value of column "WCRI_COUNT_ETECH_FUND_HIGH_TECH_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_ETECH_FUND_HIGH_TECH_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0704Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

    Then I expect value of column "WCRI_COUNT_BALANCE_FUND" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT_BALANCE_FUND from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0717Y6' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='SECSHRECLS')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                                 | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | GroupInvestment                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GroupInvestment  from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_2='Eastspring Investments India Equity TWD'                |
      | MorningstarCategory                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MorningstarCategory  from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_4='EAA Fund India Equity'                              |
      | AsOfDate                               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AsOfDate from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and trunc(w.as_of_tms)=to_date('28-02-2021','DD-MM-YYYY') and as_of_dtdf_sok = '20210228' |
      | FirmName                               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FirmName from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_5='Eastspring Securities Invst Tr Co Ltd'                          |
      | ISIN                                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ISIN from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_3='TW000T0723Y4'                                                       |
      | FundSize                               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FundSize from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.USR_VAL_CAMT_2='20000'                                                              |

      | ReturnCumulative1Month                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RETURN_1M_CAMT='5.79015'                                              |
      | Peergrouprank1Month                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='2'                                                  |
      | Noofinvestmentsrankedinpeergroup1Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_1M_PGRP_PART_NUM='3'                              |
      | Peergrouppercentile1Month              | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_1M_PGRP_PCTL_NUM='50'                                          |
      | Peergroupquartile1Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_1M_PGRP_QRTL_NUM='2'                                             |

      | ReturnCumulative3Month                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative3Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RETURN_3M_CAMT='11.271878'                                            |
      | Peergrouprank3Month                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank3Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_3M_PGRP_RNK_NUM='2'                                                  |
      | Noofinvestmentsrankedinpeergroup3Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_3M_PGRP_PART_NUM='3'                              |
      | Peergrouppercentile3Month              | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile3Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_3M_PGRP_PCTL_NUM='50'                                          |
      | Peergroupquartile3Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile3Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_3M_PGRP_QRTL_NUM='2'                                             |

      | ReturnCumulative6Month                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RETURN_6M_CAMT='20.210839'                                            |
      | Peergrouprank6Month                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_6M_PGRP_RNK_NUM='1'                                                  |
      | Noofinvestmentsrankedinpeergroup6Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_6M_PGRP_PART_NUM='3'                              |
      | Peergrouppercentile6Month              | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_6M_PGRP_PCTL_NUM='1'                                           |
      | Peergroupquartile6Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_6M_PGRP_QRTL_NUM='1'                                             |

      | ReturnCumulativeYTD                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulativeYTD from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.YTD_RETURN_CAMT='4.255992'                                               |
      | PeergrouprankYTD                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeergrouprankYTD from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.YTD_RET_PGRP_RNK_NUM='2'                                                    |
      | NoofinvestmentsrankedinpeergroupYTD    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NoofinvestmentsrankedinpeergroupYTD from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.YTD_RET_PGRP_PART_NUM='3'                                |
      | PeergrouppercentileYTD                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeergrouppercentileYTD from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.YTD_RET_PGRP_PCTL_NUM='50'                                            |
      | PeergroupquartileYTD                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeergroupquartileYTD from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.YTD_RET_PGRP_QRTL_NUM='2'                                               |

      | ReturnCumulative1Year                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative1Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.CUM_1YR_RETURN_CAMT='8.675647'                                         |
      | Peergrouprank1Year                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank1Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='3'                                               |
      | Noofinvestmentsrankedinpeergroup1Year  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PART_NUM='3'                           |
      | Peergrouppercentile1Year               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile1Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PCTL_NUM='100'                                      |
      | Peergroupquartile1Year                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile1Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_QRTL_NUM='4'                                          |

      | ReturnAnnualized2Year                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnAnnualized2Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_2YR_RETURN_CAMT='8.004181'                                          |
      | Peergrouprank2Year                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank2Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_2Y_RET_PGRP_RNK_NUM='3'                                                |
      | Noofinvestmentsrankedinpeergroup2Year  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup2Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_2Y_RET_PGRP_PART_NUM='3'                            |
      | Peergrouppercentile2Year               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile2Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_2Y_RET_PGRP_PCTL_NUM='100'                                       |
      | Peergroupquartile2Year                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile2Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_2Y_RET_PGRP_QRTL_NUM='4'                                           |

      | ReturnAnnualized3Year                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnAnnualized3Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_3YR_RETURN_CAMT='4.010745'                                          |
      | Peergrouprank3Year                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank3Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_3Y_RET_PGRP_RNK_NUM='2'                                                |
      | Noofinvestmentsrankedinpeergroup3Year  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_3Y_RET_PGRP_PART_NUM='3'                            |
      | Peergrouppercentile3Year               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile3Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_3Y_RET_PGRP_PCTL_NUM='50'                                        |
      | Peergroupquartile3Year                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile3Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_3Y_RET_PGRP_QRTL_NUM='2'                                           |

      | ReturnAnnualized5Year                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnAnnualized5Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_5YR_RETURN_CAMT='10.100843'                                         |
      | Peergrouprank5Year                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank5Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_5Y_RET_PGRP_RNK_NUM='1'                                                |
      | Noofinvestmentsrankedinpeergroup5Year  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup5Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_5Y_RET_PGRP_PART_NUM='3'                            |
      | Peergrouppercentile5Year               | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile5Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_5Y_RET_PGRP_PCTL_NUM='1'                                         |
      | Peergroupquartile5Year                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile5Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_5Y_RET_PGRP_QRTL_NUM='1'                                           |

      | ReturnAnnualized10Year                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnAnnualized10Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_10YR_RETURN_CAMT='5.827122'                                        |
      | Peergrouprank10Year                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank10Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_10Y_RET_PGRP_RNK_NUM='1'                                              |
      | Noofinvestmentsrankedinpeergroup10Year | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup10Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_10Y_RET_PGRP_PART_NUM='2'                          |
      | Peergrouppercentile10Year              | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouppercentile10Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_10Y_RET_PGRP_PCTL_NUM='1'                                       |
      | Peergroupquartile10Year                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergroupquartile10Year from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.AN_10Y_RET_PGRP_QRTL_NUM='1'                                         |

  Scenario: Remove files already present in directory before running update scenario

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Run Excel to CSV Peer Ranking workflow for update file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Taiwan Peer Ranking Report Update_20210309.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_TW_LBU                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | FILEPATTERN             | *Taiwan*.xls                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | LOAD_FILE_PATTERNS      | Processed_*Taiwan*.csv                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | PARALLELISM             | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | SUCCESS_ACTION          | LEAVE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | LIST_SHEET_NAME         | TW Balance Fund,TW E-Tech Fund and High Tech Fu,TW Export Fund and Essence Fund,TW Global Bond FOF,TW Global Equity FOF,TW Global High Yield Bond Fund,TW QQ Fund,TW Small Capital Fund,TW Well Pool MM Fund,TW European Fund Customised,TW Asia Pac HY Fund Customised,TW Brazil Eq Fund Customised,TW China Eq Fund Customised,TW Asia Pac Infra Fund Customis,TW Asia Pac REITs Fund Customis,TW US High Tech Fund Customised,TW Glb Green Fund Customised,TW India Eq Fund Customised |
      | REPROCESSPROCESSEDFILES | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_UPDATE_TWLBU} |

  Scenario: Perform checks in WCRI for checking update scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      select count(*) as WCRI_COUNT from FT_T_WCRI
      where data_src_id = 'MSTWLBU' AND dw_status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                 | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | Peergrouprank1Month    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Peergrouprank1Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='3'       |
      | ReturnCumulative6Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ReturnCumulative6Month from ft_w_wcri w where data_src_id = 'MSTWLBU' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok = (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='TW000T0723Y4' and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_status_num =1 and w.RETURN_6M_CAMT='21.210839' |